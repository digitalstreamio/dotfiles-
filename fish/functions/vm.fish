function vm
    set -l name $argv[1]
    qemu-system-x86_64 \
        -enable-kvm \
        -machine q35 \
        -bios /usr/share/edk2-ovmf/x64/OVMF.fd \
        -cpu host \
        -m 2048 \
        -nic bridge,br=br0,model=virtio-net-pci \
        -drive file=/data/vms/$name.qcow2,media=disk,if=virtio \
        -device virtio-vga-gl \
        -display gtk,gl=on \
        -cdrom /data/vms/archlinux-2022.01.01-x86_64.iso \
        -boot menu=on 
end
