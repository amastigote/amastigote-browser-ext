#!/bin/bash

#AUTH hwding
#DATE AUG/23/2017
#DESC pack a minimized but installable extension for ama-open ver

target="installable-ama-ext.zip"

if [ -a "$target" ]; then
    rm "$target"
fi

zip -r "$target" . \
    -x art/\* \
    -x coffee/\* \
    -x README.md \
    -x LICENSE \
    -x pack.sh \
    -x .git/\*
