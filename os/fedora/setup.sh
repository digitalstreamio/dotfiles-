#!/bin/bash

set -euxo pipefail

if [[ $EUID != 0 ]]; then
    echo 'Elevating privileges'
    exec sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS "$0" "$@"
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BUILD_DIR="/tmp/build"
CARCH=aarch64
PREFIX="/usr/local"

repos=(
    https://www.scala-sbt.org/sbt-rpm.repo
    #https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
)

desktop_group=sway-desktop-environment

desktop_packages=(
    # desktop / core
    sddm-wayland-sway
    wofi
    # desktop / apps
    alacritty
    # desktop / utils
    brightnessctl
    blueman
    flatpak
    gnome-keyring
    pavucontrol
    # desktop / assets
    mozilla-fira-sans-fonts
)

app_packages=(
    # app / internet
    firefox
    chromium
)

app_flatpaks=(
    # app / internet
    #org.mozilla.firefox
    #org.chromium.Chromium
    io.github.NhekoReborn.Nheko
    #us.zoom.Zoom
    # multimedia
    io.freetubeapp.FreeTube 
    com.calibre_ebook.calibre
    io.mpv.Mpv
    org.gimp.GIMP
    #com.spotify.Client
    # app / office
    #org.libreoffice.LibreOffice
    md.obsidian.Obsidian
    # utils
    org.gnome.Evince
    org.gnome.eog
    org.gnome.meld
    org.keepassxc.KeePassXC
    # app / dev
    #com.google.AndroidStudio
    com.jetbrains.IntelliJ-IDEA-Community
    com.visualstudio.code
    # app / emulators
    net.fsuae.FS-UAE
    net.sf.VICE
    # ext / sys
    org.gtk.Gtk3theme.Adwaita-dark
)

util_packages=(
    # util / shell
    fish
    # util / tui
    #lf
    micro
    atop
    htop
    lnav
    ncdu
    # util / cli
    bat
    croc
    fd-find
    fzf
    just
    procs
    rclone
    ripgrep
    sd
    tealdeer
    telnet
    #xh
)

util_bins=(
    "lf https://github.com/gokcehan/lf/releases/download/r32/lf-linux-arm64.tar.gz"
)

util_builds=(
    xh    
)

dev_packages=(
    # dev / lang
    clang
    golang
    java-17-openjdk-devel
    python3
    rust
    #nodejs
    # dev / build
    cargo
    cmake
    make
    sbt
    # dev / ops
    ansible
    helm
    #k9s
    opentofu
    podman
    podman-compose
    # dev / tools
    git
    gitui
    git-delta
    python3-ipython
    tokei
    #wrk
    # dev / libraries
    openssl-devel
)

dev_bins=(
    "k9s https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_arm64.tar.gz"
)

dev_ext_vscode=(
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

sys_services_disable=(
    abrtd
    atd
    chronyd
    rsyslog
    smartd
)

sys_services_enable=(
    systemd-timesyncd
)

user_services=(
    ssh-agent.service
    waybar.service
)

install_binary() {
    local pkgname="$1"
    local pkgver=1
    local pkgurl="$2"
    local pkgdir="$PREFIX"

    cd "$BUILD_DIR"
    rm -rf "$pkgname-$pkgver" || true
    mkdir -p "$pkgname-$pkgver"

    wget -O "$pkgname.tar.gz" "$pkgurl"
    tar xavf "$pkgname.tar.gz" -C "$pkgname-$pkgver" 

    pushd .
    cd "$pkgname-$pkgver"
    install -Dm 755 "$pkgname" -t "$pkgdir/bin"
    popd

    rm -rf "$pkgname-$pkgver" || true
}

install_pkgbuild() {
    local pkgspec="$1"
    pkgdir="$PREFIX"
    source "${SCRIPT_DIR}/pkgbuild/${pkgspec}"
    
    cd "$BUILD_DIR"
    rm -rf "$pkgname-$pkgver" || true
    mkdir -p "$pkgname-$pkgver"

    download_pkg "${source//::/#}" "$pkgname-$pkgver" 
    
    pushd .
    prepare
    popd
    
    pushd .
    build
    popd
    
    pushd .
    check
    popd 

    pushd .
    package
    popd

    rm -rf "$pkgname-$pkgver" || true
}

download_pkg() {
    local source="$1"
    local dst_dir="$2"
    IFS="#" read -r name url <<< "$source"
    wget -O "$name" "$url"
    tar xavf "$name" -C "$dst_dir" --strip 1
}

install_apps() {
    dnf install "${app_packages[@]}"
    flatpak install --or-update --noninteractive "${app_flatpaks[@]}"
}

install_desktop() {
    dnf group install "${desktop_group}"
    dnf install "${desktop_packages[@]}"
}

install_dev() {
    dnf install "${dev_packages[@]}"

    for pair in "${dev_bins[@]}"; do
        IFS=' ' read -r name url <<< "$pair"
        install_binary "$name" "$url"
    done
}

install_dev_ext() {
    if [[ -n "$SUDO_USER" ]]; then
        if command -v com.visualstudio.code &> /dev/null; then
            for ext in "${dev_ext_vscode[@]}"; do
                sudo -u "$SUDO_USER" --preserve-env=DBUS_SESSION_BUS_ADDRESS com.visualstudio.code --install-extension $ext
            done
        fi
    fi
}

install_repos() {
    for repo in "${repos[@]}"; do
        dnf config-manager --add-repo $repo 
    done
}

install_utils() {
    dnf install "${util_packages[@]}"

    for pair in "${util_bins[@]}"; do
        IFS=' ' read -r name url <<< "$pair"
        install_binary "$name" "$url"
    done

    for pkg in "${util_builds[@]}"; do
        install_pkgbuild "$pkg"
    done
}

install_utils_ext() {
    for pkg in "${util_builds[@]}"; do
        install_pkgbuild "$pkg"
    done
}

config_system() {
    systemctl disable --now "${sys_services_disable[@]}"
    systemctl enable --now "${sys_services_enable[@]}"
    timedatectl set-ntp true
}

config_user() {
    # curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
    # fisher install jethrokuan/z
    systemctl --user enable "${user_services[@]}"
}

main() {
    mkdir -p $BUILD_DIR

    case "$1" in
        install-desktop) install_desktop ;;
        install-apps) install_apps ;;
        install-dev) install_dev ;;
        install-dev-ext) install_dev_ext ;;
        install-repos) install_repos ;;
        install-utils) install_utils ;;
        install-utils-ext) install_utils_ext ;;
        config-system) config_system ;;
        config-user) config_user ;;
        *) echo "Invalid action ${1}!"; exit 1 ;;
    esac
}

main $*
