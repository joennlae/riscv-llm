# build rootfs
# more infos here https://github.com/carlosedp/riscv-bringup/blob/master/Ubuntu-Rootfs-Guide.md
# docker run -it --rm --privileged --cap-add=ALL --net=host -v/dev:/dev -v/lib/modules:/lib/modules:ro -v/home/janniss/mounts/docker:/out qemu-base
apt install debootstrap qemu qemu-user-static binfmt-support dpkg-cross --no-install-recommends -y
apt install qemu-user-static qemu-system qemu-utils qemu-system-misc binfmt-support -y

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

debootstrap --arch=riscv64 --foreign jammy ./temp-rootfs http://ports.ubuntu.com/ubuntu-ports
cp /usr/bin/qemu-riscv64-static temp-rootfs/usr/bin

chroot temp-rootfs /bin/bash
/debootstrap/debootstrap --second-stage

# Add package sources
cat >/etc/apt/sources.list <<EOF
deb http://ports.ubuntu.com/ubuntu-ports jammy main restricted

deb http://ports.ubuntu.com/ubuntu-ports jammy-updates main restricted

deb http://ports.ubuntu.com/ubuntu-ports jammy universe
deb http://ports.ubuntu.com/ubuntu-ports jammy-updates universe

deb http://ports.ubuntu.com/ubuntu-ports jammy multiverse
deb http://ports.ubuntu.com/ubuntu-ports jammy-updates multiverse

deb http://ports.ubuntu.com/ubuntu-ports jammy-backports main restricted universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports jammy-security main restricted
deb http://ports.ubuntu.com/ubuntu-ports jammy-security universe
deb http://ports.ubuntu.com/ubuntu-ports jammy-security multiverse
EOF

## use the lunar to install gcc-13 later :-)

# Install essential packages
apt-get update
apt-get install --no-install-recommends -y util-linux haveged openssh-server systemd kmod initramfs-tools conntrack ebtables ethtool iproute2 iptables mount socat ifupdown iputils-ping vim dhcpcd5 neofetch sudo chrony


# Create base config files
mkdir -p /etc/network
cat >>/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

cat >/etc/resolv.conf <<EOF
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

cat >/etc/fstab <<EOF
LABEL=rootfs	/	ext4	user_xattr,errors=remount-ro	0	1
EOF

echo "Ubuntu-riscv64" > /etc/hostname

# Disable some services on Qemu
ln -s /dev/null /etc/systemd/network/99-default.link
ln -sf /dev/null /etc/systemd/system/serial-getty@hvc0.service

# Set root passwd
echo "root:riscv" | chpasswd

sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Clean APT cache and debootstrap dirs
rm -rf /var/cache/apt/

exit 

tar -cSf Ubuntu-Jammy-rootfs.tar -C temp-rootfs .
gzip Ubuntu-Jammy-rootfs.tar
# rm -rf temp-rootfs