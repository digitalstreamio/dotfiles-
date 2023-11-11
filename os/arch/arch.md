Arch Installation Guide
=======================

# Vars

INSTALL_DEV=/dev/vda; \
export NODE_HOSTNAME=nova; \
export NODE_USER=raytracer; \
export MIRROR_REGION=us; \
export LOCALE=en_US; \
export KEYBOARD_LAYOUT=us; \
export TIMEZONE=America/New_York; \
export NETWORK_SSID=ssid

# Disk Setup / Basic

sgdisk --clear \
    --new=1:0:+512MiB --typecode=1:ef00 --change-name=1:EFI \
    --new=2:0:0       --typecode=2:8304 --change-name=2:system \
    ${INSTALL_DEV}; \
sleep 1; \
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI; \
mkfs.btrfs -f -L system /dev/disk/by-partlabel/system; \
mount -t btrfs LABEL=system /mnt; \
mkdir -p /mnt/boot; \
mount /dev/disk/by-partlabel/EFI /mnt/boot

# Disk Setup / Encrypted

## erase
cryptsetup open --type plain ${INSTALL_DEV} container --key-file /dev/urandom; \
dd if=/dev/zero of=/dev/mapper/container status=progress bs=1M; \
cryptsetup close container

## partition
sgdisk --clear \
    --new=1:0:+1GiB --typecode=1:ef00 --change-name=1:EFI \
    --new=2:0:0     --typecode=2:8304 --change-name=2:cryptsystem \
    ${INSTALL_DEV}

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

reflector --country ${MIRROR_REGION} --protocol https --sort score --latest 10 --save /etc/pacman.d/mirrorlist; \
pacstrap /mnt base linux linux-lts linux-firmware btrfs-progs dracut efibootmgr iwd openssh sudo; \
genfstab -L -p /mnt >> /mnt/etc/fstab

# Configuration

arch-chroot /mnt; 

echo "LANG=${LOCALE}.UTF-8" > /etc/locale.conf; \
echo "KEYMAP=${KEYBOARD_LAYOUT}" > /etc/vconsole.conf; \
echo "${LOCALE}.UTF-8 UTF-8" >> /etc/locale.gen; \
locale-gen; \
ln -s "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime; \
hwclock --systohc; \
echo "${NODE_HOSTNAME}" > /etc/hostname; \
echo "127.0.1.1 ${NODE_HOSTNAME}.localdomain ${NODE_HOSTNAME}" >> /etc/hosts

# Users

echo "Set root password"; \
passwd; \
useradd -m -G wheel,users ${NODE_USER}; \
echo "Set user ${NODE_USER} password"; \
passwd ${NODE_USER}; \
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

# Networking

cat > /etc/systemd/network/wired.network <<EOF
[Match]
Name=en*
[Network]
DHCP=yes
EOF
systemctl enable systemd-networkd; \
systemctl enable systemd-resolved; \
systemctl enable sshd

echo > /etc/iwd/main.conf >>EOF
[General]
EnableNetworkConfiguration=true
EOF
iwctl station wlan0 connect ${NETWORK_SSID}; \
systemctl enable iwd

# Bootloader / Basic

pacman -S --asdeps binutils elfutils; \
for kver in /lib/modules/*; do dracut -f --uefi --kver "${kver##*/}"; done; \
bootctl install

# Bootloader / Encrypted

## unified kernel
pacman -S --asdeps binutils elfutils

deviceuuid=$(blkid -s UUID -o value /dev/disk/by-partlabel/cryptsystem)

cat > /etc/dracut.conf.d/cmdline.conf <<EOF
kernel_cmdline="root=/dev/mapper/system rootflags=subvol=@,discard,noatime rd.luks.name=${deviceuuid}=system rw quiet mitigations=off"
EOF

for kver in /lib/modules/*; do dracut -f --uefi --kver "${kver##*/}"; done

## bootloader
bootctl install; \
cat > /boot/loader/loader.conf <<EOF
default linux-*-lts-*
editor no
EOF

# Reboot

exit
reboot
