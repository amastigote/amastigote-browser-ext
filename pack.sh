#!/bin/bash

#@author: hwding
#@date: AUG/19/2017
#@description: package a minified extension for ama-open

zip -r installable-ama-ext.zip . -x art/\* -x coffee/\* -x README.md -x pack.sh
