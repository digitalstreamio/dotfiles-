#!/bin/bash

set -xeuo pipefail

if [[ $EUID != 0 ]]; then
	echo 'Elevating privileges'
	exec sudo --preserve-env=AUR_PAGER,PACKAGER,DBUS_SESSION_BUS_ADDRESS "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# base:		1530MB/128
# sys:		380MB/+69
# desktop:	714MB/+203
# dev:		1678MB/+71

sys_packages=(
	# sys / base
	base 
	linux 
	linux-lts 
	linux-firmware 
	btrfs-progs 
	dracut 
	efibootmgr 
	sudo
	# sys / servcies
	firewalld
	fwupd
	openssh
	zram-generator
	# sys / utils
	bat
	curl
	fish
	fzf
	hexyl
	htop
	iotop
	jq
	lnav
	lsof
	man-db
	man-pages
	mc
	mdcat
	micro
	nmap
	powertop
	ripgrep
	rsync
	tldr
	w3m
	zstd
	pacman-contrib
	pkgfile
)

dev_packages=(
	# dev / base
	base-devel 
	git 
	linux-headers 
	linux-lts-headers
	# dev / lang
	jdk11-openjdk
	python
	rustup
	# dev / ops
	ansible
	fabric
	helm
	minikube
	kompose
	kubectl
	podman
	toolbox
	# dev / utils
	tig
	tokei
)

desktop_packages=(
	# desktop / assets
	ttf-caladea
	ttf-carlito
	ttf-dejavu
	ttf-droid
	ttf-font-awesome
	ttf-liberation
	# desktop / shell
	sway
	swayidle
	swaylock
	waybar
	wofi
	rofi
	mako
	# desktop / services
	cups
	pipewire-pulse
	wireplumber
	xorg-xwayland
	# desktop / tools
	alacritty
	dconf-editor
	flatpak
	gnome-keyring
	grim
	light
	pcmanfm-gtk3
	wl-clipboard
	xdg-desktop-portal-gtk
	xdg-desktop-portal-wlr
	xdg-user-dirs
	xdg-utils
)

aur_packages=(
	corrupter-bin
	greetd
	sway-systemd
	todotxt
)

apps=(
	# internet
	org.mozilla.firefox
	org.chromium.Chromium
	# multimedia
	org.blender.Blender
	org.gimp.GIMP
	org.inkscape.Inkscape
	fr.handbrake.ghb
	# office
	org.libreoffice.LibreOffice
	# utils
	org.gnome.Evince
	org.gnome.eog
	org.gnome.meld
	org.keepassxc.KeePassXC
	# emulators
	net.fsuae.FS-UAE
	net.sf.VICE
	# dev
	com.google.AndroidStudio
	com.jetbrains.IntelliJ-IDEA-Community
	com.visualstudio.code
	org.freedesktop.Sdk.Extension.openjdk11//21.08
)

configs=(
	# system
	etc/ssh/sshd_config
	etc/modules-load.d/zram.conf
	etc/sysctl.d/00-ansible.conf
	etc/systemd/journald.conf.d/00-ansible.conf
	etc/systemd/zram-generator.conf
	etc/udev/rules.d/00-ansible.rules
	# desktop
	etc/greetd/config.toml
	usr/lib/systemd/user/ssh-agent.service
	usr/lib/systemd/user/swayidle.service
	usr/lib/systemd/user/waybar.service
)

scripts=(
	bin/sway-run.sh
)

services=(
	# system
	firewalld.service
	sshd.service
	systemd-networkd.service
	systemd-resolved.service
	systemd-timesyncd.service
	# desktop
	cupsd.service
	greetd.service
	# timers
	fstrim.timer
	paccache.timer
	pkgfile-update.timer
)

user_services=(
	ssh-agent.service
	swayidle.service
	waybar.service
)

install_packages() {
	pacman -Syu --needed "${sys_packages[@]}" "${dev_packages[@]}" "${desktop_packages[@]}"
}

install_apps() {
	flatpak install --or-update --noninteractive "${apps[@]}"
	
	flatpak override org.mozilla.firefox --socket=wayland --env=MOZ_ENABLE_WAYLAND=1
}

install_aur() {
	if [[ -n "$SUDO_USER" ]]; then
		sudo -u "$SUDO_USER" bash <<-'EOF'
		set -xeuo pipefail
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

install_user() {
	if [[ -n "$SUDO_USER" ]]; then
		sudo -u "$SUDO_USER" rustup toolchain install stable
	fi
}

config_system() {
	for config in "${configs[@]}"; do
		install -Dpm644 "$DIR/$config" /$config
	done

	for script in "${scripts[@]}"; do
		install -pm755 "$DIR/$script" /usr/local/$script
	done

	systemctl daemon-reload
	
	for service in "${services[@]}"; do
		systemctl enable $service
	done
	
	systemctl start /dev/zram0
	systemctl set-default graphical.target
}

config_user() {
	if [[ -n "$SUDO_USER" ]]; then
		for service in "${user_services[@]}"; do
			sudo -u "$SUDO_USER" --preserve-env=DBUS_SESSION_BUS_ADDRESS systemctl --user enable $service
		done
	fi
}

main() {
	case "$1" in
		all)
			install_packages
			install_apps
			install_user
			install_aur
			config_system
			config_user
			;;
		install-packages)
			install_packages ;;
		install-apps) 
			install_apps ;;
		install-aur) 
			install_aur ;;
		install-user) 
			install_user ;;
		config-system) 
			config_system ;;
		config-user) 
			config_user ;;
		pkg-sys) 
			pacman -Syu --needed "${sys_packages[@]}" ;;
		pkg-dev)
			pacman -Syu --needed "${dev_packages[@]}" ;;
		pkg-desktop)
			pacman -Syu --needed "${desktop_packages[@]}" ;;
		*) 
			echo "Invalid action ${1}!"; exit 1 ;;
	esac
}

main $*
