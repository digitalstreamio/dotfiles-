#!/bin/sh

set -a
[ -f "$HOME/.config/sway/env" ] && . "$HOME/.config/sway/env"
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
set +a

systemd-cat --identifier=sway sway $@
