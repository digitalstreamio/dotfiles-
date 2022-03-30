#!/bin/bash

set -euxo pipefail

IMAGE=/data/vms/archvm.qcow2
OS_IMAGE=/data/vms/archlinux-2022.03.01-x86_64.iso

qemu-system-x86_64 \
    -enable-kvm \
    -machine q35 \
    -bios /usr/share/edk2-ovmf/x64/OVMF.fd \
    -cpu host \
    -m 2048 \
    -nic bridge,br=br0,model=virtio-net-pci \
    -drive file=$IMAGE,media=disk,if=virtio \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    -cdrom $OS_IMAGE \
    -boot menu=on 
