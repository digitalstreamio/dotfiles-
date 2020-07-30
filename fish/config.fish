set -gx PATH $PATH ~/.local/bin ~/.cargo/bin ~/sdk/flutter/bin
set -gx ANDROID_HOME ~/sdk/android
set -gx DFS_HOST_INT 192.168.1.11
set -gx FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(code {})+abort'"
set -gx TERM xterm-color

# cli
alias cat='bat'
alias help='tldr'
alias pv="fzf --preview 'bat --color \"always\" {}'"
alias jn='journalctl'
alias sd='systemctl'
