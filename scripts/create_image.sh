# Updated version of https://github.com/carlosedp/riscv-bringup/blob/master/Qemu/Readme.md
# Build inside of docker container
# docker run -it --rm --privileged --cap-add=ALL --net=host -v/dev:/dev -v/lib/modules:/lib/modules:ro -v/home/janniss/mounts/docker:/out qemu-base
# to have ndb working

apt install wget -y

export PREFIX="/opt/riscv"
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./configure --prefix=$PREFIX --with-arch=rv64imafd_zicsr_zifencei --with-abi=lp64d
make linux -j $(nproc)

export PATH=/opt/riscv/bin:$PATH
echo "export PATH=/opt/riscv/bin:$PATH" >> ~/.bashrc

# clone repos
mkdir qemu-boot
cd qemu-boot

# OpenSBI
git clone https://github.com/riscv-software-src/opensbi
# U-Boot
git clone https://github.com/U-Boot/U-Boot u-boot
# Linux Kernel
git clone https://github.com/torvalds/linux

# build u-boot

cd u-boot
git checkout v2023.10

apt install libssl-dev -y # needed

# Build
CROSS_COMPILE=riscv64-unknown-linux-gnu- make qemu-riscv64_smode_defconfig
# CROSS_COMPILE=riscv64-unknown-linux-gnu- make menuconfig # optional
CROSS_COMPILE=riscv64-unknown-linux-gnu- make -j $(nproc)
cd ..

cd opensbi

git checkout v1.3.1
make CROSS_COMPILE=riscv64-unknown-linux-gnu- \
     PLATFORM=generic \
     FW_PAYLOAD_PATH=../u-boot/u-boot.bin

cd ..

# build linux
cd linux
git checkout v6.5

# make CROSS_COMPILE=riscv64-unknown-linux-gnu- ARCH=riscv menuconfig # to configure
make CROSS_COMPILE=riscv64-unknown-linux-gnu- ARCH=riscv defconfig
make CROSS_COMPILE=riscv64-unknown-linux-gnu- ARCH=riscv -j $(nproc)

# kernel modules
apt install kmod -y

rm -rf modules_install
mkdir -p modules_install
CROSS_COMPILE=riscv64-unknown-linux-gnu- ARCH=riscv make modules_install INSTALL_MOD_PATH=./modules_install
version=`cat include/config/kernel.release`
echo $version

cd modules_install/lib/modules

tar -cf kernel-modules-${version}.tar .
gzip kernel-modules-${version}.tar

cd ../../../

mv ./modules_install/lib/modules/kernel-modules-${version}.tar.gz .

# qemu image
apt install qemu-user-static qemu-system qemu-utils qemu-system-misc binfmt-support -y
# create image
cd ..

qemu-img create -f qcow2 riscv64-QemuVM.qcow2 10G
modprobe nbd max_part=16
qemu-nbd -c /dev/nbd0 riscv64-QemuVM.qcow2

apt install fdisk -y

sfdisk /dev/nbd0 << 'EOF'
label: dos
label-id: 0x17527589
device: /dev/nbd0
unit: sectors

/dev/nbd0p1 : start=        2048, type=83, bootable
EOF

mkfs.ext4 /dev/nbd0p1
e2label /dev/nbd0p1 rootfs

mkdir rootfs
mount /dev/nbd0p1 rootfs

wget -O rootfs.tar.bz2 https://github.com/carlosedp/riscv-bringup/releases/download/v1.0/UbuntuFocal-riscv64-rootfs.tar.gz

cd rootfs
tar vxf ../rootfs.tar.bz2

# Unpack Kernel modules
mkdir -p lib/modules
tar vxf ../linux/kernel-modules-$version.tar.gz -C ./lib/modules

mkdir -p boot/extlinux
cp ../linux/arch/riscv/boot/Image boot/vmlinuz-$version

# Create uboot extlinux file
cat << EOF | tee boot/extlinux/extlinux.conf
menu title RISC-V Qemu Boot Options
timeout 100
default kernel-$version

label kernel-$version
        menu label Linux kernel-$version
        kernel /boot/vmlinuz-$version
        initrd /boot/initrd.img-$version
        append earlyprintk rw root=/dev/vda1 rootwait rootfstype=ext4 LANG=en_US.UTF-8 console=ttyS0

label rescue-kernel-$version
        menu label Linux kernel-$version (recovery mode)
        kernel /boot/vmlinuz-$version
        initrd /boot/initrd.img-$version
        append earlyprintk rw root=/dev/vda1 rootwait rootfstype=ext4 LANG=en_US.UTF-8 console=ttyS0 single
EOF

cd ..

## patch riscv64 support
cat > /tmp/qemu-riscv64 <<EOF
package qemu-user-static 
type magic
offset 0
magic \x7f\x45\x4c\x46\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00
mask \xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff
interpreter /usr/bin/qemu-riscv64-static
EOF

update-binfmts --unimport qemu-riscv64
update-binfmts --import /tmp/qemu-riscv64   

# update-binfmts --display qemu-riscv64
update-binfmts --enable qemu-riscv64

## end patch riscv64 support

cp /usr/bin/qemu-riscv64-static rootfs/usr/bin

chroot rootfs update-initramfs -k all -c

umount rootfs
qemu-nbd -d /dev/nbd0

mkdir qemu-vm
mv riscv64-QemuVM.qcow2 qemu-vm
cp opensbi/build/platform/generic/firmware/fw_payload.bin qemu-vm

# Create start script
cat > qemu-vm/start_riscv.sh << 'EOF'
#!/bin/bash

# List here required TCP and UDP ports to be exposed on Qemu
TCPports=(4419 38188 8080 6443 8443 9090 9093)
UDPports=(4419 38188)

LocalSSHPort=22222

for port in ${TCPports[@]}
do
  ports=hostfwd=tcp::$port-:$port,$ports
done
for port in ${UDPports[@]}
do
  ports=hostfwd=udp::$port-:$port,$ports
done

ports=$ports"hostfwd=tcp::$LocalSSHPort-:22"

qemu-system-riscv64 \
    -nographic \
    -machine virt \
    -smp 8 \
    -m 8G \
    -bios fw_payload.bin \
    -device virtio-blk-device,drive=hd0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-device,rng=rng0 \
    -drive file=riscv64-QemuVM.qcow2,format=qcow2,id=hd0 \
    -device virtio-net-device,netdev=usernet \
    -netdev user,id=usernet,$ports
EOF

# Create start script
cat > qemu-vm/ssh.sh << 'EOF'
#!/bin/bash
ssh -p 22222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost
EOF

chmod +x qemu-vm/start_riscv.sh qemu-vm/ssh.sh
tar -cf riscv64-QemuVM.tar qemu-vm
gzip riscv64-QemuVM.tar

# start it once in recovery mode and then good it is fixed :-)