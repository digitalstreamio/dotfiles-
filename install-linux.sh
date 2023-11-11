#!/bin/sh
cp -r * ~/.config/
cp -r app ~/.var/
cp -r xdg/fedora/applications ~/.local/share/
cp .profile ~/.profile

# fisher install jethrokuan/z
# fisher install jethrokuan/fzf
# fisher install edc/bass
# lpadmin -p Canon-G6000 -E -v ipps://192.168.4.50 -m everywhere
# flatpak override com.visualstudio.code --user \
#    --env=ANDROID_SDK_ROOT=$HOME/sdk/android \
#    --env=JAVA_HOME=/usr/lib/sdk/openjdk11 \
#    --env=SHELL=/usr/bin/bash \
#    --env=PATH=/app/bin:/usr/bin:/usr/lib/sdk/openjdk11/bin:$HOME/.cargo/bin:$HOME/sdk/flutter/bin
