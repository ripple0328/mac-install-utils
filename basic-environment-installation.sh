#!/usr/bin/env bash

source /dev/stdin  <<< "$(curl -s https://raw.github.com/ripple0328/mac-install-utils/master/install-utils.sh)"

# get permisson at beginning

get-root-permisson

# add dependencies
install-brew
install-git
install-brew-cask
install-utils
