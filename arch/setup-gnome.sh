#!/bin/bash

set -euxo pipefail

if [[ $EUID != 0 ]]; then
	echo 'Elevating privileges'
	exec sudo --preserve-env=AUR_PAGER,PACKAGER,DBUS_SESSION_BUS_ADDRESS "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

core_packages=(
    # system / base
    base 
    linux 
    linux-firmware 
    linux-lts 
    btrfs-progs 
    dracut 
    efibootmgr 
    intel-ucode
    openssh
    sudo
    # system / services
	bolt
    firewalld
    fwupd
    iwd
    power-profiles-daemon
    # system / utils
    fish
    iptables-nft
	# system / extras
    man-db
    man-pages
    pacman-contrib
    pacutils
    pkgfile
	reflector
)

desktop_packages=(
    # desktop / base
    gdm
    gnome-control-center
	# desktop / apps
    alacritty
    nautilus
	# desktop / utils
    flatpak
    xdg-user-dirs
    xdg-utils
    # desktop / extras
    gnome-backgrounds
    gnome-themes-extra
    ttf-caladea
    ttf-carlito
    ttf-dejavu
    ttf-droid
    ttf-font-awesome
    ttf-liberation
)

aur_packages=(
	dracut-hook-uefi
)

apps=(
	org.chromium.Chromium
	io.mpv.Mpv
	com.visualstudio.code
	org.gtk.Gtk3theme.Adwaita-dark
)

sys_services=(
	# system
	firewalld.service
	sshd.service
	systemd-networkd.service
	systemd-resolved.service
	systemd-timesyncd.service
	# system timers
	fstrim.timer
	paccache.timer
	pkgfile-update.timer
)

install_aur() {
	if [[ -n "$SUDO_USER" ]] && ! command -v paru &> /dev/null; then
		sudo -u "$SUDO_USER" bash <<-'EOF'
		set -euxo pipefail
		BUILDDIR=$(mktemp -d --tmpdir aur.XXXXXXXX)
		cd "$BUILDDIR"
		git clone --depth=1 "https://aur.archlinux.org/paru-bin"
		cd paru-bin
		makepkg --noconfirm --nocheck -csi
		EOF
	fi
	if [[ -n "$SUDO_USER" ]]; then
		sudo -u "$SUDO_USER" --preserve-env=AUR_PAGER,PACKAGER paru -S "${aur_packages[@]}"
	fi
}

config_system() {
	for service in "${sys_services[@]}"; do
		systemctl enable --now $service
	done
	
	timedatectl set-ntp true
	ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

	flatpak override org.chromium.Chromium --socket=wayland
	flatpak override com.visualstudio.code --socket=wayland --env=JAVA_HOME=/usr/lib/sdk/openjdk11 --env=SHELL=/usr/bin/bash
}

main() {
	case "$1" in
		install-system) pacman -Syu --needed "${core_packages[@]}" "${desktop_packages[@]}" ;;
		install-apps) flatpak install --or-update --noninteractive "${apps[@]}" ;;
		install-aur) install_aur ;;
		config-system) config_system ;;
		*) echo "Invalid action ${1}!"; exit 1 ;;
	esac
}

main $*
