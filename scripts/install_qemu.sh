
# install libslirp
export PREFIX_LIB="$PWD/install/libslirp"
cd deps/libslirp
meson -Dprefix=$PREFIX_LIB build
ninja -C build install
cd ../..

## install script for QEMU

export PREFIX="$PWD/install/qemu"

cd deps/qemu
./configure --target-list=riscv64-softmmu --prefix=$PREFIX --enable-slirp
make -j $(nproc)
make install
