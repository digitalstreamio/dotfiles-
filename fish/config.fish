set -gx FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(code {})+abort'"

# aliases
alias cat='bat'
alias help='tldr'
alias jn='journalctl'
alias pv="fzf --preview 'bat --color \"always\" {}'"
alias sd='systemctl'
