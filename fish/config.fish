if status is-interactive
    # Commands to run in interactive sessions can go here
    if test "$(uname)" = "Darwin"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        fish_add_path "$HOME/.cargo/bin"
        fish_add_path "$HOME/Library/Python/3.10/bin"
        set -gx JAVA_HOME "$(/usr/libexec/java_home -v 11)"
    end

    # Exports
    set -gx NODE_CLUSTER esprit
    set -gx NODE_SERVICE_IP 127.0.0.1

    # Aliases
    alias cat='bat'
    alias help='tldr'
    alias pv="fzf --preview 'bat --color \"always\" {}'"
    alias podstart="podman machine start"
    alias podstop="podman machine stop"
    alias podup="podman start --all"
    alias poddown="podman stop --all"
    
    if test "$(uname)" = "Linux"
        alias cr='chromium'
        alias code='com.visualstudio.code --enable-features=UseOzonePlatform --ozone-platform=wayland'
        alias jd='journalctl'
        alias sd='systemctl'
        alias pacq="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
    end
end
