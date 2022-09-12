#!/bin/sh

case "$1" in
    *.md) glow -s dark "$1";;
    *.pdf) pdftotext "$1" -;;
    *.tar*) tar tf "$1";;
    *.zip) unzip -l "$1";;
    *) bat "$1";;
esac
