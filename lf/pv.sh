#!/bin/sh

case "$1" in
    *.pdf) pdftotext "$1" -;;
    *.tar*) tar tf "$1";;
    *.zip) unzip -l "$1";;
    *.jpg|*.jpeg|*.png) mediainfo "$1";;
    *.m4v|*.mkv|*.mov|*.mp4) mediainfo "$1";;
    *) bat "$1";;
esac
