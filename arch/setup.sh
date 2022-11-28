#!/bin/bash

set -euxo pipefail

if [[ $EUID != 0 ]]; then
	echo 'Elevating privileges'
	exec sudo --preserve-env=AUR_PAGER,PACKAGER,DBUS_SESSION_BUS_ADDRESS "$0" "$@"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# base:		950MB/140
# core:		430MB/95
# desktop:	540MB/189
# dev:		2138MB/208

core_packages=(
	# sys / base
	base 
	linux 
	linux-firmware 
	linux-lts 
	btrfs-progs 
	dracut 
	efibootmgr 
	intel-ucode
	sudo
	# sys / apps
	fish
	atop
	htop
	micro
	lnav
	ncdu
	nnn
	# sys / services
	bolt
	firewalld
	fwupd
	iwd
	openssh
	udisks2
	zram-generator
	# sys / utils
	bat
	exa
	fd
	fzf
	glow
	ripgrep
	tealdeer
	# sys / utils / networking
	curl
	gnu-netcat
	inetutils
	iptables-nft
	rclone
	rsync
	sshfs
	tcpdump
	# sys / extras
	lostfiles
	man-db
	man-pages
	pacman-contrib
	pacutils
	pkgfile
	reflector
	unzip
	zstd
	usbutils
)

desktop_packages=(
	# desktop / base
	sway
	swaybg
	swayidle
	swaylock
	waybar
	wofi
	# desktop / apps
	alacritty
	pcmanfm-gtk3
	# desktop / services
	mako
	pipewire-pulse
	wireplumber
	xorg-xwayland
	# desktop / utils
	colord
	dconf-editor
	flatpak
	gnome-keyring
	grim
	jq
	light
	wl-clipboard
	xdg-desktop-portal-gtk
	xdg-desktop-portal-wlr
	xdg-user-dirs
	xdg-utils
	# desktop / extras
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
	# dev / langs
	clang
	jdk11-openjdk
	jdk17-openjdk
	nodejs-lts-fermium
	python
	#rustup
	# dev / ops
	ansible
	fabric
	monit
	libvirt
	podman
	qemu-desktop
	terraform
	helm
	minikube
	kompose
	kubectl
	# dev / utils
	android-udev
	cmake
	dnsmasq
	edk2-ovmf
	edk2-shell
	git-delta
	github-cli
	meson
	ninja
	podman-docker
	python-decorator
	python-poetry
	tig
	tokei
	wrk
)

aur_packages=(
	# system / base
	dracut-hook-uefi
	# system / tui
	lf
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
	io.mpv.Mpv
	org.blender.Blender
	org.gimp.GIMP
	org.inkscape.Inkscape
	#fr.handbrake.ghb
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
	usr/lib/systemd/user/waybar.service
)

sys_scripts=(
	bin/sway-run.sh
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
	# desktop
	greetd.service
	# dev
	monit.service
)

user_services=(
	ssh-agent.service
	waybar.service
)

vscode_extensions=(
    # langs
    dart-code.flutter
    ms-python.vscode-pylance
    rust-lang.rust-analyzer
    # ops
	redhat.ansible
    ms-azuretools.vscode-docker
	HashiCorp.terraform
	# tools
	eamodio.gitlens
	ms-python.black-formatter
)

install_system() {
	pacman -Syu --needed "${core_packages[@]}" "${desktop_packages[@]}" "${dev_packages[@]}"
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
		install -pm755 "$DIR/$script" /usr/local/$script
	done

	systemctl daemon-reload
	
	for service in "${sys_services[@]}"; do
		systemctl enable --now $service
	done
	
	systemctl start /dev/zram0
	timedatectl set-ntp true

	ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

	if [[ ! -d /data ]]; then
		mkdir -p /data
		chattr +C /data
	fi
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
		usermod -aG libvirt $SUDO_USER
		
		sudo -u "$SUDO_USER" bash <<-'EOF'
		if [[ ! -d ~/.minikube ]]; then
			mkdir ~/.minikube
			chattr +C ~/.minikube
		fi
		EOF
	fi
}

config_desktop() {
	if [[ -n "$SUDO_USER" ]]; then
		sudo -u "$SUDO_USER" bash <<-'EOF'
		gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
		gsettings set org.gnome.desktop.interface font-antialiasing rgba
		gsettings set org.gnome.desktop.interface font-hinting slight
		EOF
	fi
}

main() {
	case "$1" in
		all)
			install_system
			install_apps
			install_user
			install_aur
			config_system
			config_apps
			config_user
			;;
		install-system) install_system ;;
		install-apps) install_apps ;;
		install-aur) install_aur ;;
		install-user) install_user ;;
		config-system) config_system ;;
		config-apps) config_apps ;;
		config-desktop) config_desktop ;;
		config-user) config_user ;;
		install-core) pacman -Syu --needed "${core_packages[@]}" ;;
		install-desktop) pacman -Syu --needed "${desktop_packages[@]}" ;;
		install-dev) pacman -Syu --needed "${dev_packages[@]}" ;;
		*) echo "Invalid action ${1}!"; exit 1 ;;
	esac
}

main $*
