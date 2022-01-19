set -gx FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(code {})+abort'"

# aliases
alias cat='bat'
alias help='tldr'
alias jn='journalctl'
alias pv="fzf --preview 'bat --color \"always\" {}'"
alias sd='systemctl'
alias pac-all="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
alias pac-installed="pacman -Qq | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
