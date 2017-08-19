#!/bin/bash

#AUTH hwding
#DATE AUG/19/2017
#DESC package a minified extension for ama-open

zip -r installable-ama-ext.zip . -x art/\* -x coffee/\* -x README.md -x pack.sh
