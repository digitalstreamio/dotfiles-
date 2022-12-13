#starship init fish | source
alias cat='bat'
alias cr='org.chromium.Chromium -enable-features=UseOzonePlatform -ozone-platform=wayland'
alias code='com.visualstudio.code'
alias help='tldr'
alias jn='journalctl'
alias pv="fzf --preview 'bat --color \"always\" {}'"
alias sd='systemctl'
alias pacall="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse"
alias paci="pacman -Qq | fzf --preview 'pacman -Qil {}' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'"
