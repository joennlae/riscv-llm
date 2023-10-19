# build linux for riscv

cd deps/linux
export ARCH=riscv
export CROSS_COMPILE=riscv64-buildroot-linux-gnu-
export CFLAGS="-march=rv64imafd_zicsr_zifencei"
make defconfig
make