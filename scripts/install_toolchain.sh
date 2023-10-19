# install toolchain

export PREFIX="$PWD/install/toolchain"
# --with-arch=rv64gc --with-abi=lp64d # The build defaults to targeting RV64GC (64-bit) with glibc
cd deps/riscv-toolchain
./configure --prefix=$PREFIX --with-arch=rv64imafd_zicsr_zifencei --with-abi=lp64d
make linux # -j $(nproc)


# install toolchain

# mkdir -p $PREFIX
# cd $PREFIX
# wget https://toolchains.bootlin.com/downloads/releases/toolchains/riscv64-lp64d/tarballs/riscv64-lp64d--glibc--stable-2023.08-1.tar.bz2
# tar -xvf riscv64-lp64d--glibc--stable-2023.08-1.tar.bz2
# mv riscv64-lp64d--glibc--stable-2023.08-1 riscv64-lp64d
# rm riscv64-lp64d--glibc--stable-2023.08-1.tar.bz2