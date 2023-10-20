# clean env

export BASE_PATH="/usr/scratch/schneematt/janniss/Documents/riscv-explore"
# Toolchain paths
export TOOLCHAIN="$BASE_PATH/install/toolchain/riscv64-lp64d"
export PATH="$TOOLCHAIN/bin:$PATH"
export PATH="$TOOLCHAIN/riscv64-buildroot-linux-gnu/bin:$PATH"

# QEMU paths

## libslirp
export LD_LIBRARY_PATH="$BASE_PATH/install/libslirp/lib64:$LD_LIBRARY_PATH"
# QEMU
export QEMU_PREFIX="$BASE_PATH/install/qemu"
export PATH="$QEMU_PREFIX/bin:$PATH"
alias qemu="$QEMU_PREFIX/bin/qemu-system-riscv64"
