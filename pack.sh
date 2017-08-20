#!/bin/bash

#AUTH hwding
#DATE AUG/21/2017
#DESC package a minimized extension for ama-open

zip -r installable-ama-ext.zip . \
    -x art/\* \
    -x coffee/\* \
    -x README.md \
    -x pack.sh \
    -x .git/\*
