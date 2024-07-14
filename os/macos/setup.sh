#!/usr/bin/env bash

apps=(
    # app / internet
    firefox
    google-chrome
    chatgpt
    nheko
    zoom
    # app / media
    freetube
    calibre
    iina
    spotify
    # app / office
    libreoffice
    obsidian
    # app / utils
    appcleaner
    keepassxc
    raycast
    rectangle
    # app / dev
    android-studio
    clion
    intellij-idea-ce
    visual-studio-code
    zed
)

appstore=(
    # iMovie
    408981434 
    # Wireguard
    1441195209
)

utils=(
    # util / shell
    fish
	# util / tui
    lf
    micro
    htop
    lnav
    ncdu
    # util / cli
    bat
    croc
    fd
    fzf
    just
    procs
    rclone
    ripgrep
    sd
    tealdeer
    telnet
    xh
    dog
    glow
)

dev=(
    # dev / lang
    go
    node
    openjdk
    python
    rust
    # dev / build
    cmake
    maven
    ninja
    sbt
    # dev / ops
    ansible
    fabric
    helm
	k9s
    podman
    podman-compose
    qemu
    terraform
    # dev / tools
    git
    gitui
    git-delta
    ipython
    tokei
    wrk
    zerotier-one
)

config_system() {
    sudo systemsetup -settimezone "America/New_York" > /dev/null
    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
    echo “/opt/homebrew/bin/fish” | sudo tee -a /etc/shells

    disable_spotlight
}

config_user() {
    # Appearance
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    # Enable subpixel font rendering on non-Apple LCDs
    # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
    defaults write NSGlobalDomain AppleFontSmoothing -int 1
    # Keyboard/Trackpad/Mouse
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5
    defaults write com.apple.HIToolbox AppleFnUsageType -int 0
    # Dock
    defaults write com.apple.Dock autohide -bool true
    defaults write com.apple.Dock autohide-delay -float 0.1
    defaults write com.apple.Dock autohide-time-modifier -float 0.5
    defaults write com.apple.Dock show-process-indicators -bool true
    defaults write com.apple.Dock wvous-bl-corner -int 1
    defaults write com.apple.dock wvous-bl-modifier -int 0
    defaults write com.apple.Dock wvous-br-corner -int 1
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
    # Shortcuts
    defaults write org.mozilla.firefox NSUserKeyEquivalents -dict \
        "New Tab" "^t" \
        "New Window" "^n" \
        "New Private Window" "^\$n" \
        "Close Tab" "^w" \
        "Close Window" "^\$w" \
        "Find in Page..." "^f" \
        "Find Again" "^g" 

    chsh -s /opt/homebrew/bin/fish
    
    disable_siri
}

config_reset() {
    defaults write com.apple.dock persistent-apps -array
}

disable_siri() {
    defaults write com.apple.assistant.backedup 'Use device speaker for TTS' -int 3
    defaults write com.apple.assistant.support 'Assistant Enabled' -bool false
    defaults write com.apple.assistant.support 'Siri Data Sharing Opt-In Status' -int 2
    defaults write com.apple.SetupAssistant 'DidSeeSiriSetup' -bool True
    defaults write com.apple.Siri 'StatusMenuVisible' -bool false
    defaults write com.apple.Siri 'UserHasDeclinedEnable' -bool true
    defaults write com.apple.systemuiserver 'NSStatusItem Visible Siri' 0

    launchctl disable "user/$UID/com.apple.assistantd"
    launchctl disable "gui/$UID/com.apple.assistantd"
    launchctl disable "user/$UID/com.apple.Siri.agent"
    launchctl disable "gui/$UID/com.apple.Siri.agent"
    #sudo launchctl disable 'system/com.apple.assistantd'
    #sudo launchctl disable 'system/com.apple.Siri.agent'
}

disable_spotlight() {
    sudo mdutil -a -i off
    sudo mdutil -X /
}

show_status() {
	echo "* Spotlight"
	mdutil -s /
	echo "* FileValut"
	fdesetup status
	echo "* SIP"
	csrutil status
	echo "* Assessment"
	spctl --status
}

main() {
	case "$1" in
		install-apps) brew install --cask "${apps[@]}" ;;
        install-appstore) mas install "${appstore[@]}" ;;
		install-dev) brew install "${dev[@]}" ;;
		install-utils) brew install "${utils[@]}" ;;
        config-system) config_system ;;
		config-user) config_user ;;
        config-reset) config_reset ;;
        show-status) show_status ;;
		*) echo "Invalid action ${1}!"; exit 1 ;;
	esac
}

main $*
