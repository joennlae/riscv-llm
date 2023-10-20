#!/bin/bash

# List here required TCP and UDP ports to be exposed on Qemu
TCPports=(4419 38188 8080 6443 8443 9090 9093)
UDPports=(4419 38188)

LocalSSHPort=22222

for port in ${TCPports[@]}
do
  ports=hostfwd=tcp::$port-:$port,$ports
done
for port in ${UDPports[@]}
do
  ports=hostfwd=udp::$port-:$port,$ports
done

ports=$ports"hostfwd=tcp::$LocalSSHPort-:22"

qemu-system-riscv64 \
    -nographic \
    -machine virt \
    -cpu rv64,v=true,zba=true,vlen=128 \
    -smp 8 \
    -m 8G \
    -bios fw_payload.bin \
    -device virtio-blk-device,drive=hd0 \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-device,rng=rng0 \
    -drive file=riscv64-QemuVM.qcow2,format=qcow2,id=hd0 \
    -device virtio-net-device,netdev=usernet \
    -netdev user,id=usernet,$ports \
    &> system.log &
