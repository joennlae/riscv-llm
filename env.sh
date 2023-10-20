
# clean env


# Toolchain paths
export TOOLCHAIN="$PWD/install/toolchain/riscv64-lp64d"
export PATH="$TOOLCHAIN/bin:$PATH"
export PATH="$TOOLCHAIN/riscv64-buildroot-linux-gnu/bin:$PATH"

# QEMU paths

## libslirp
export LD_LIBRARY_PATH="$PWD/install/libslirp/lib64:$LD_LIBRARY_PATH"
# QEMU
export QEMU_PREFIX="$PWD/install/qemu"
export PATH="$QEMU_PREFIX/bin:$PATH"
alias qemu="$QEMU_PREFIX/bin/qemu-system-riscv64"


## iis has sshpass not installed...
export PATH="$PWD/install/sshpass/usr/bin:$PATH"