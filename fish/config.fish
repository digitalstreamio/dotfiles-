set -gx FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(code {})+abort'"

# cli
alias cat='bat'
alias help='tldr'
alias pv="fzf --preview 'bat --color \"always\" {}'"
alias jn='journalctl'
alias sd='systemctl'
