# RISC-V LLM (using QEMU for now)

This repository is used for some preliminary testing of the RISCV-LLM project. It is based on the [RISC-V Getting Started Guide](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html) and the [RISCV-Bringup](https://github.com/carlosedp/riscv-bringup/blob/master/Qemu/Readme.md) repository.

## CI

[![LLM Inference Test](https://github.com/joennlae/riscv-llm/actions/workflows/llm-tests.yml/badge.svg)](https://github.com/joennlae/riscv-llm/actions/workflows/llm-tests.yml)
[![RISC-V Vector Intrinsics Test](https://github.com/joennlae/riscv-llm/actions/workflows/intrinsic-test.yml/badge.svg)](https://github.com/joennlae/riscv-llm/actions/workflows/intrinsic-test.yml)
[![RISC-V Ubuntu 22.04 Booting](https://github.com/joennlae/riscv-llm/actions/workflows/boot-test.yml/badge.svg)](https://github.com/joennlae/riscv-llm/actions/workflows/boot-test.yml)

## Features

* RISC-V QMEU setup running Ubuntu22.04 with RISC-V Vector Extension (RVV) v1.0      (v0.7.1 is not supported in QEMU)
* GCC 13.2 with RVV 1.0 support including RVV intrinsics v0.11
* CI Pipeline for building and testing the RISC-V LLM project

## Llama 2 7B Example

One example taken from the CI:

```txt
What do you think about RISC-V?

RISC-V (RISC Virtual Machine) is an open-source instruction set architecture (ISA) that was designed to be simple, efficient, and extensible. It was first introduced in 2010 by the University of California, Berkeley and is now maintained by the RISC-V Foundation, a non-profit organization.
```


## Setup

### Install QEMU from scratch

Run

```bash
git submodule update --init --recursive
./scripts/install_qemu.sh
source env.sh

# download the vm
wget https://iis.ee.ethz.ch/~janniss/scratch_schneematt/ubuntu-riscv-vector-new.tar.gz
tar -xvf ubuntu-riscv-vector-new.tar.gz \
    && mv ubuntu-22.04-gcc-13-backup/ ubuntu-riscv-vector/ \
    && rm ubuntu-riscv-vector-new.tar.gz
cd ubuntu-riscv-vector

# boot the VM
./start_riscv.sh
```

### Docker setup

There is a prepared docker image. Which includes the RISC-V VM.

```bash
docker pull ghcr.io/joennlae/qemu-riscv-vec
docker run -it --rm ghcr.io/joennlae/qemu-riscv-vec
```

### Resources

* https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html
* https://www.qemu.org/docs/master/system/riscv/virt.html
* https://github.com/carlosedp/riscv-bringup/blob/master/Qemu/Readme.md