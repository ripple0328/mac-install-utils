#!/usr/bin/env bash

source /dev/stdin  <<< "$(curl -s https://raw.github.com/ripple0328/mac-install-utils/master/install-utils.sh)"

# get permisson at beginning

get-root-permission

# add dependencies
install-brew
check-and-brew-install zsh
install-git
install-brew-cask
install-utils
