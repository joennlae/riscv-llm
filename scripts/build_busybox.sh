# building busybox

CROSS_COMPILE="riscv64-unknown-linux-gnu-"

cd deps/busybox
make defconfig
make -j $(nproc)