#!/bin/sh
cp -r * ~/.config/
cp .profile ~/.profile

usermod -s /usr/bin/fish $USER
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fisher add jethrokuan/z
fisher add jethrokuan/fzf
fisher add edc/bass

flatpak override com.visualstudio.code --user \
    --env=ANDROID_SDK_ROOT=$HOME/sdk/android \
    --env=JAVA_HOME=/usr/lib/sdk/openjdk11 \
    --env=SHELL=/usr/bin/bash \
    --env=PATH=/app/bin:/usr/bin:/usr/lib/sdk/openjdk11/bin:$HOME/.cargo/bin:$HOME/sdk/flutter/bin
