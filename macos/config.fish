if status is-interactive
    # Commands to run in interactive sessions can go here
    eval "$(/opt/homebrew/bin/brew shellenv)"
    fish_add_path "$HOME/.cargo/bin"
    fish_add_path "$HOME/Library/Python/3.10/bin"
    set -gx JAVA_HOME "$(/usr/libexec/java_home -v 11)"
    set -gx NODE_CLUSTER esprit
    set -gx NODE_SERVICE_IP 127.0.0.1
end
