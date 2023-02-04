#!/usr/bin/env bash

apps=(
    # internet
    firefox
    google-chrome
    # office
    libreoffice
    # utils
    appcleaner
    rectangle
    zerotier-one
    # dev
    android-studio
    intellij-idea-ce
    visual-studio-code
)

appstore=(
    # iMovie
    408981434 
)

dev=(
    # lang
    go
    node
    openjdk
    python@3.10
    # ops
    ansible
    fabric
    podman
    qemu
    terraform
    # tools
    cmake
    git-delta
    maven
    ninja
    sbt
    tig
    tokei
    wrk
)

utils=(
    bat
    dog
    eva
    exa
    fd
    fish
    fzf
    glow
    htop
    lf
    lnav
    mas
    micro
    ncdu
    procs
    rclone
    ripgrep
    tealdeer
    telnet
)

install_apps() {
	brew install --cask "${apps[@]}"
}

install_appstore() {
	mas install "${appstore[@]}"
}

install_dev() {
	brew install "${dev[@]}"
}

install_utils() {
	brew install "${utils[@]}"
}

config_system() {
    sudo systemsetup -settimezone "America/New_York" > /dev/null
    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    echo “/opt/homebrew/bin/fish” | sudo tee -a /etc/shells
}

config_user() {
    # System
    defaults write NSGlobalDomain AppleLanguages -array "en-US"
    defaults write NSGlobalDomain AppleLocale -string "en_US"
    # Appearance
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    # Enable subpixel font rendering on non-Apple LCDs
    # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
    defaults write NSGlobalDomain AppleFontSmoothing -int 1
    # Dock
    defaults write com.apple.Dock autohide -bool true
    defaults write com.apple.Dock autohide-delay -float 0.1
    defaults write com.apple.Dock autohide-time-modifier -float 0
    defaults write com.apple.Dock show-process-indicators -bool true
    defaults write com.apple.Dock wvous-bl-corner -int 1
    defaults write com.apple.dock wvous-bl-modifier -int 0
    defaults write com.apple.Dock wvous-br-corner -int 13
    defaults write com.apple.dock wvous-br-modifier -int 0
    defaults write com.apple.Dock wvous-tl-corner -int 2
    defaults write com.apple.dock wvous-tl-modifier -int 0
    defaults write com.apple.Dock wvous-tr-corner -int 1
    defaults write com.apple.dock wvous-tr-modifier -int 0
    # Finder
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    defaults write com.apple.finder NewWindowTargetPath -string "file:///${HOME}/";
    defaults write com.apple.finder QuitMenuItem -bool true
    defaults write com.apple.finder ShowPathbar -bool false
    defaults write com.apple.finder ShowStatusBar -bool false
    # Keyboard/Trackpad/Mouse
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5
    defaults write com.apple.HIToolbox AppleFnUsageType -int 0
    # Shortcuts
    defaults write NSGlobalDomain NSUserKeyEquivalents -dict \
        Cut "^x" \
        Copy "^c" \
        Paste "^v" \
        Undo "^z" \
        Redo "^\$z" \
        "Select All" "^a"
    defaults write org.mozilla.firefox NSUserKeyEquivalents -dict \
        "New Tab" "^t" \
        "New Window" "^n" \
        "Close Tab" "^w" \
        "Find in Page..." "^f"

    chsh -s /opt/homebrew/bin/fish
}

config_reset() {
    defaults write com.apple.dock persistent-apps -array
}

main() {
	case "$1" in
		install-apps) install_apps ;;
        install-appstore) install_appstore ;;
		install-dev) install_dev ;;
		install-utils) install_utils ;;
        config-system) config_system ;;
		config-user) config_user ;;
        config-reset) config_reset ;;
		*) echo "Invalid action ${1}!"; exit 1 ;;
	esac
}

main $*
