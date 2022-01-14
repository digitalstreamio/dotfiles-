Arch Installation Guide
=======================

# Disk Setup

NODE_INSTALL_DEV=/dev/vda

sgdisk --clear \
    --new=1:0:+512MiB --typecode=1:ef00 --change-name=1:EFI \
    --new=2:0:0       --typecode=2:8304 --change-name=2:system \
    ${NODE_INSTALL_DEV}; \
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI; \
mkfs.btrfs -L system /dev/disk/by-partlabel/system; \
mount -t btrfs LABEL=system /mnt; \
mkdir -p /mnt/boot; \
mount /dev/disk/by-partlabel/EFI /mnt/boot

# Installation

reflector --verbose --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist; \
pacstrap /mnt base linux linux-lts linux-firmware btrfs-progs dracut efibootmgr openssh sudo; \
genfstab -L -p /mnt >> /mnt/etc/fstab

# Configuration

arch-chroot /mnt

NODE_HOSTNAME=nova; \
NODE_USER=raytracer; \
NODE_LOCALE=en_US.UTF-8; \
NODE_KEYMAP=us; \
NODE_TIMEZONE=America/New_York

echo "${NODE_LOCALE} UTF-8" >> /etc/locale.gen; \
echo "KEYMAP=${NODE_KEYMAP}" > /etc/vconsole.conf; \
locale-gen; \
localectl set-locale LANG=${NODE_LOCALE}; \
localectl set-keymap ${NODE_KEYMAP}; \
timedatectl set-ntp true; \
timedatectl set-timezone ${NODE_TIMEZONE}; \
hwclock --systohc; \
hostnamectl set-hostname ${NODE_HOSTNAME}; \
echo "127.0.1.1	${NODE_HOSTNAME}.localdomain	${NODE_HOSTNAME}" >> /etc/hosts; \
systemctl enable systemd-networkd; \
systemctl enable systemd-resolved; \
systemctl enable sshd

cat > /etc/systemd/network/10-wired.network <<EOF
[Match]
Name=en*
[Network]
DHCP=yes
EOF

# User

passwd

echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel; \
useradd -m ${NODE_USER}; \
usermod -aG wheel ${NODE_USER}; \
passwd ${NODE_USER}

# Bootloader

pacman -S --asdeps binutils elfutils
for kver in /lib/modules/*; do dracut -f --uefi --kver "${kver##*/}"; done
bootctl install

# Reboot
exit
reboot
