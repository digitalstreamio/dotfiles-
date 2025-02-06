#!/usr/bin/env bash

apps=(
    # internet
    firefox
    google-chrome
    nheko
    zoom
    # media
    spotify
    calibre
    handbrake
    iina
    # productivity
    obsidian
    chatgpt
    lm-studio
    # utils
    alacritty
    keepassxc
    menumeters
    rectangle
    #verve
    # dev
    zed
    android-studio
    clion
    intellij-idea-ce
)

appstore=(
    # DaVinci Resolve
    571213070
    # Wireguard
    1441195209
    # Xcode
    497799835
)

utils=(
	# essential
    fish
    lf
    micro
    lnav
    television
    # net
    croc
    rclone
    xh
    # sys
    bat
    fd
    ripgrep
    sd
    tealdeer
    # sysinfo
    btop
    htop
    ncdu
)

dev=(
    # lang
    go
    node@22
    openjdk@11
    python
    rust
    # build
    cmake
    coursier
    pnpm
    sbt
    # llm
    huggingface-cli
    # ops
    ansible
    fabric
    helm
	k9s
	opentofu
    podman
    podman-compose
    qemu
    # tools
    git
    gitui
    git-delta
    just
    pipx
    telnet
    tokei
    wrk
    zerotier-one
)

pipx=(
	aider-chat
	mlx-lm
)

llm_lms=(
	lmstudio-community/DeepSeek-R1-Distill-Qwen-32B-GGUF@Q4_K_M
	lmstudio-community/Mistral-Small-24B-Instruct-2501-GGUF@Q8_0
)

# pipx install aider-chat --python /opt/homebrew/bin/python3.12

install_llm() {
    if command -v code &> /dev/null; then
        for model in "${llm_lms[@]}"; do
            lms get $model
        done
    fi
}

config_system() {
    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
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
    defaults write com.apple.Dock wvous-bl-corner -int 11
    defaults write com.apple.dock wvous-bl-modifier -int 0
    defaults write com.apple.Dock wvous-br-corner -int 1
    defaults write com.apple.dock wvous-br-modifier -int 0
    defaults write com.apple.Dock wvous-tl-corner -int 2
    defaults write com.apple.dock wvous-tl-modifier -int 0
    defaults write com.apple.Dock wvous-tr-corner -int 1
    defaults write com.apple.dock wvous-tr-modifier -int 0
    
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
    launchctl disable "user/$UID/com.apple.SiriTTSTrainingAgent"
    launchctl disable "gui/$UID/com.apple.SiriTTSTrainingAgent"    
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
        install-llm) install_llm ;;
		install-utils) brew install "${utils[@]}" ;;
        config-system) config_system ;;
		config-user) config_user ;;
        config-reset) config_reset ;;
        status) show_status ;;
		*) echo "Invalid action ${1}!"; exit 1 ;;
	esac
}

main $*
