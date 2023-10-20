# RISCV-LLM-QEMU

This repository is used for some preliminary testing of the RISCV-LLM project. It is based on the [RISC-V Getting Started Guide](https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html) and the [RISCV-Bringup](https://github.com/carlosedp/riscv-bringup/blob/master/Qemu/Readme.md) repository.

## Features

* RISC-V QMEU setup running Ubuntu22.04 with RISC-V Vector Extension (RVV) v1.0      (v0.7.1 is not supported in QEMU)
* CI Pipeline for building and testing the RISC-V LLM project
* GCC 13.2 with RVV 1.0 support including intrinsics v0.11

## Setup

### Install QEMU from scratch

### Docker setup

### Resources

* https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html
* https://www.qemu.org/docs/master/system/riscv/virt.html
* https://github.com/carlosedp/riscv-bringup/blob/master/Qemu/Readme.md