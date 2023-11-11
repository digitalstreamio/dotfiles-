if status is-interactive
    # Commands to run in interactive sessions can go here
    if test "$(uname)" = "Darwin"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        fish_add_path "$HOME/.cargo/bin"
        fish_add_path "$HOME/Library/Python/3.10/bin"
        set -gx JAVA_HOME "$(/usr/libexec/java_home -v 11)"
    end

    # Aliases
    alias cat='bat'
    alias help='tldr'
    alias pv="fzf --preview 'bat --color \"always\" {}'"
    alias podup="podman machine start"
    alias poddown="podman machine stop"
    alias podstart="podman start --all"
    alias podstop="podman stop --all"
    
    if test "$(uname)" = "Linux"
        alias code='com.visualstudio.code --ozone-platform-hint=auto'
        alias cr='chromium-browser --ozone-platform-hint=auto'
        alias jn='journalctl'
        alias sc='systemctl'
        #alias pmq="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
    end

    # Exports
    set -gx NODE_CLUSTER esprit
    set -gx NODE_SERVICE_IP 127.0.0.1
    set -gx ANDROID_HOME "$HOME/sdk/android"
    set -gx FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(code {})+abort'"
end
