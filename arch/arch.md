Arch Installation Guide
=======================

# Disk Setup

## vars
NODE_INSTALL_DEV=/dev/vda

## erase
cryptsetup open --type plain ${NODE_INSTALL_DEV} container --key-file /dev/urandom; \
dd if=/dev/zero of=/dev/mapper/container status=progress bs=1M; \
cryptsetup close container

## partition
sgdisk --clear \
    --new=1:0:+512MiB --typecode=1:ef00 --change-name=1:EFI \
    --new=2:0:0       --typecode=2:8304 --change-name=2:cryptsystem \
    ${NODE_INSTALL_DEV}

## format
cryptsetup luksFormat /dev/disk/by-partlabel/cryptsystem; \
cryptsetup open /dev/disk/by-partlabel/cryptsystem system; \
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI; \
mkfs.btrfs -L system /dev/mapper/system

## mount
o_btrfs=defaults,discard,noatime,compress=zstd:1; \
mount -t btrfs LABEL=system /mnt; \
btrfs subvolume create /mnt/@; \
btrfs subvolume create /mnt/@home; \
btrfs subvolume create /mnt/@snapshots; \
umount -R /mnt; \
mount -t btrfs -o subvol=@,$o_btrfs LABEL=system /mnt; \
mkdir -p /mnt/{boot,home,.snapshots}; \
mount -t btrfs -o subvol=@home,$o_btrfs LABEL=system /mnt/home; \
mount -t btrfs -o subvol=@snapshots,$o_btrfs LABEL=system /mnt/.snapshots; \
mount /dev/disk/by-partlabel/EFI /mnt/boot

# Installation

## mirrors
reflector --verbose --country 'United States' --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

## base install
pacstrap /mnt base linux linux-lts linux-firmware btrfs-progs dracut efibootmgr openssh sudo

## fstab 
genfstab -L -p /mnt >> /mnt/etc/fstab

# Configuration

## chroot
arch-chroot /mnt

## vars
NODE_HOSTNAME=nova; \
NODE_USER=raytracer; \
NODE_LOCALE=en_US.UTF-8; \
NODE_KEYMAP=us; \
NODE_TIMEZONE=America/New_York

## locale, timezone, hostname, networking
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

## root password
passwd

## user
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel; \
useradd -m ${NODE_USER}; \
usermod -aG wheel ${NODE_USER}; \
passwd ${NODE_USER}

# Bootloader 

## unified kernel
pacman -S --asdeps binutils elfutils

deviceuuid=$(blkid -s UUID -o value /dev/disk/by-partlabel/cryptsystem)

cat > /etc/dracut.conf.d/cmdline.conf <<EOF
kernel_cmdline="root=/dev/mapper/system rw rootflags=subvol=@,discard,noatime rd.luks.name=${deviceuuid}=system mitigations=off"
EOF

for kver in /lib/modules/*; do dracut -f --uefi --kver "${kver##*/}"; done

## bootloader
bootctl install

cat > /boot/loader/loader.conf <<EOF
default linux-*-lts-*
timeout 4
console-mode max
editor no
EOF

## reboot
exit
reboot
