#!/bin/bash

set -euxo pipefail

if [[ $EUID != 0 ]]; then
	echo 'Elevating privileges'
	exec sudo --preserve-env=AUR_PAGER,PACKAGER,DBUS_SESSION_BUS_ADDRESS "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# base:		1530MB/125
# sys:		350MB/73
# desktop:	620MB/206
# dev:		1670MB/93

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
	# sys / services
	firewalld
	fwupd
	openssh
	udisks2
	zram-generator
	# sys / utils
	bat
	curl
	fish
	fzf
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
	ncdu
	nmap
	pacman-contrib
	pkgfile
	powertop
	reflector
	ripgrep
	rsync
	tealdeer
	unzip
	usbutils
	w3m
	zstd
)

de_packages=(
	# desktop / shell
	sway
	swayidle
	swaylock
	waybar
	wofi
	# desktop / services
	colord
	cups
	mako
	pipewire-pulse
	wireplumber
	xorg-xwayland
	# desktop / apps
	alacritty
	pcmanfm-gtk3
	# desktop / utils
	dconf-editor
	flatpak
	ghostscript
	gnome-keyring
	grim
	light
	wl-clipboard
	xdg-desktop-portal-gtk
	xdg-desktop-portal-wlr
	xdg-user-dirs
	xdg-utils
	# desktop / assets
	gnome-themes-extra
	ttf-caladea
	ttf-carlito
	ttf-dejavu
	ttf-droid
	ttf-font-awesome
	ttf-liberation
)

dev_packages=(
	# dev / base
	base-devel 
	git 
	# dev / libs
	linux-headers 
	linux-lts-headers
	# dev / langs
	clang
	jdk11-openjdk
	nodejs-lts-erbium
	python
	#rustup
	# dev / ops
	ansible
	fabric
	monit
	podman
	qemu
	terraform
	#helm
	#toolbox
	#minikube
	#kompose
	#kubectl
	# dev / utils
	edk2-ovmf
	edk2-shell
	git-delta
	github-cli
	ninja
	podman-docker
	python-decorator
	tig
	tokei
)

aur_packages=(
	# system
	dracut-hook-uefi
	# desktop
	corrupter-bin
	greetd
	sway-systemd
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
	org.gnome.Calculator
	org.gnome.Evince
	org.gnome.eog
	org.gnome.meld
	org.keepassxc.KeePassXC
	# dev
	com.google.AndroidStudio
	com.jetbrains.IntelliJ-IDEA-Community
	com.visualstudio.code
	# emulators
	net.fsuae.FS-UAE
	net.sf.VICE
	# ext / sys
	org.gtk.Gtk3theme.Adwaita-dark
	# ext / dev
	org.freedesktop.Sdk.Extension.openjdk11//21.08
)

sys_configs=(
	# system
	etc/ssh/sshd_config
	etc/modules-load.d/zram.conf
	etc/sysctl.d/00-ansible.conf
	etc/systemd/journald.conf.d/00-ansible.conf
	etc/systemd/network/bind.network
	etc/systemd/network/br0.netdev
	etc/systemd/network/br0.network
	etc/systemd/network/wired.network
	etc/systemd/zram-generator.conf
	# desktop
	etc/greetd/config.toml
	usr/lib/systemd/user/ssh-agent.service
	usr/lib/systemd/user/swayidle.service
	usr/lib/systemd/user/waybar.service
)

sys_scripts=(
	sway-run.sh
)

sys_services=(
	# system
	firewalld.service
	sshd.service
	systemd-networkd.service
	systemd-resolved.service
	systemd-timesyncd.service
	udisks2.service
	# system timers
	fstrim.timer
	paccache.timer
	pkgfile-update.timer
	# desktop
	cups.service
	greetd.service
	# dev
	monit.service
)

user_services=(
	ssh-agent.service
	swayidle.service
	waybar.service
)

vscode_extensions=(
    # langs
    dart-code.flutter
    ms-python.vscode-pylance
    matklad.rust-analyzer
    # ops
	redhat.ansible
    ms-azuretools.vscode-docker
	hashicorp.terraf
	# tools
	eamodio.gitlens
)

install_packages() {
	pacman -Syu --needed "${sys_packages[@]}" "${de_packages[@]}" "${dev_packages[@]}"
}

install_apps() {
	flatpak install --or-update --noninteractive "${apps[@]}"
}

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

install_user() {
	if [[ -n "$SUDO_USER" ]]; then
		sudo -u "$SUDO_USER" bash <<-'EOF'
		curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
		curl https://sh.rustup.rs -sSf | sh
		EOF
	fi
}

config_system() {
	for config in "${sys_configs[@]}"; do
		install -Dpm644 "$DIR/$config" /$config
	done

	for script in "${sys_scripts[@]}"; do
		install -pm755 "$DIR/$script" /usr/local/bin/$script
	done

	systemctl daemon-reload
	
	for service in "${sys_services[@]}"; do
		systemctl enable --now $service
	done
	
	systemctl start /dev/zram0
	systemctl set-default graphical.target
	timedatectl set-ntp true

	ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
}

config_apps() {
	flatpak override org.mozilla.firefox --socket=wayland --env=MOZ_ENABLE_WAYLAND=1
	flatpak override com.visualstudio.code --socket=wayland --env=JAVA_HOME=/usr/lib/sdk/openjdk11 --env=SHELL=/usr/bin/bash
}

config_user() {
	if [[ -n "$SUDO_USER" ]]; then
		for service in "${user_services[@]}"; do
			sudo -u "$SUDO_USER" --preserve-env=DBUS_SESSION_BUS_ADDRESS systemctl --user enable $service
		done

		if command -v com.visualstudio.code &> /dev/null; then
			for ext in "${vscode_extensions[@]}"; do
				sudo -u "$SUDO_USER" --preserve-env=DBUS_SESSION_BUS_ADDRESS com.visualstudio.code --install-extension $ext
			done
		fi

		usermod -s /usr/bin/fish $SUDO_USER
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
			config_apps
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
		config-apps)
			config_apps ;;
		config-user) 
			config_user ;;
		pkg-sys) 
			pacman -Syu --needed "${sys_packages[@]}" ;;
		pkg-de)
			pacman -Syu --needed "${de_packages[@]}" ;;
		pkg-dev)
			pacman -Syu --needed "${dev_packages[@]}" ;;
		*) 
			echo "Invalid action ${1}!"; exit 1 ;;
	esac
}

main $*
