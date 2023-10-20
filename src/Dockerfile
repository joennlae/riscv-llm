FROM ubuntu:22.04

# Install dependencies
RUN apt update
RUN apt-get install build-essential wget pip pkg-config -y
# install qemu deps 
RUN apt-get install libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg8-dev libgif-dev libglib2.0-dev git -y

# install ninja and meson
RUN pip install meson ninja

RUN cd && wget https://github.com/qemu/qemu/archive/refs/tags/v8.1.2.tar.gz \
    && tar -xvf v8.1.2.tar.gz \
    && cd qemu-8.1.2 \
    && ./configure --target-list=riscv64-softmmu --enable-slirp \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm v8.1.2.tar.gz \
    && rm -rf qemu-8.1.2

# install libslirp
RUN cd && git clone https://gitlab.freedesktop.org/slirp/libslirp.git \
    && cd libslirp \
    && git checkout v4.7.0 \
    && meson build \
    && ninja -C build install \
    && cd .. \
    && rm -rf libslirp

# add to LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu

RUN cd && wget https://iis.ee.ethz.ch/~janniss/scratch_schneematt/ubuntu-riscv-vector.tar.gz \
    && tar -xvf ubuntu-riscv-vector.tar.gz \
    && mv ubuntu-22.04-gcc-13-backup/ ubuntu-riscv-vector/ \
    && rm ubuntu-riscv-vector.tar.gz

RUN apt install sshpass -y

COPY startup.sh /root/ubuntu-riscv-vector/startup.sh
COPY ssh.sh /root/ubuntu-riscv-vector/ssh.sh
COPY start_riscv.sh /root/ubuntu-riscv-vector/start_riscv.sh
COPY ssh_cmd.sh /root/ubuntu-riscv-vector/ssh_cmd.sh
COPY scp_cmd.sh /root/ubuntu-riscv-vector/scp_cmd.sh

# run script on entry
ENTRYPOINT ["/home/ubuntu-riscv-vector/startup.sh"]