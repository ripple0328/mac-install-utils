#!/usr/bin/env bash

function colors () {
    # Reset
    RESET='\e[0m'
    RED='\e[0;31m'          # Red
    GREEN='\e[0;32m'        # Green
    YELLOW='\e[0;33m'       # Yellow
    BLUE='\e[0;34m'         # Blue
    PURPLE='\e[0;35m'       # Purple
    CYAN='\e[0;36m'         # Cyan
    WHITE='\e[0;37m'        # White

    # Bold
    BRED='\e[1;31m'         # Red
    BGREEN='\e[1;32m'       # Green
    BYELLOW='\e[1;33m'      # Yellow
    BBLUE='\e[1;34m'        # Blue
    BPURPLE='\e[1;35m'      # Purple
    BCYAN='\e[1;36m'        # Cyan
    BWHITE='\e[1;37m'       # White
}
colors

CURRENT_SHELL=$(echo $0 | tr -d -)
SHELL_CONFIG_FILE=$(echo '.'$CURRENT_SHELL'rc')

function setting-cask-install-path {
    # for brew-cask
    echo 'export HOMEBREW_CASK_OPTS="--appdir=/Applications"' >> $SHELL_CONFIG_FILE
}

function setting-path {
    # for rvm
    echo 'export PATH="/usr/local/bin:$PATH"' >> $SHELL_CONFIG_FILE
}

setting-path
setting-cask-install-path

function msg {
    printf "$BGREEN 0000===--->$RESET $2 $1 $RESET\n"
}


function check-command-existence {
    msg 'CHECKING\t\t command -'$1'- existences' $BCYAN
    # command -v $1 >/dev/null 2>&1
    hash $1 2>&-
}

function is_brew_installed {
    msg 'CHECKING\t\t whether -'$1'- has been installed' $BCYAN    
    brew list | grep $1  > /dev/null 2>&- &&
    msg 'PACKAGE\t\t -'$1'- already been installed' $BYELLOW 
}

function install_brew_package {
    msg 'INSTALL\t\t -'$1'- by brew' $BPURPLE
    brew install $1 $2 
    msg 'LINKING\t\t -'$1'- to system path' $BPURPLE
    brew link $1 --force > /dev/null 2>&-
    msg 'Upgrade\t\t -'$1'-' $BPURPLE
    brew upgrade $1 > /dev/null 2>&-
}

function check-and-brew-install {
    is_brew_installed $1 ||
    msg 'PACKAGE\t\t -'$1'- not installed' $BRED &&
    install_brew_package $1 $2
}

function is-npm-packages-installed {
    msg 'CHECKING\t\t whether -'$1'- has been installed' $BCYAN    
    npm list -g --parseable | grep $1 > /dev/null 2>&-  &&
    msg 'PACKAGE\t\t -'$1'- already been installed' $BYELLOW 
}

function install-npm-package {
    msg 'INSTALL\t\t -'$1'- by npm' $BPURPLE
    npm install -g $1 > /dev/null 2>&-  
}

function check-and-npm-install {
    is-npm-packages-installed $1 ||
    msg 'PACKAGE\t\t -'$1'- not installed' $BRED &&
    install-npm-package $1
}

function is-brew-repo-tapped {
    msg 'CHECKING\t\t whether repo -'$1/$2'- has been taped' $BCYAN       
    brew tap | grep $1/$2  >/dev/null 2>&- &&
    msg 'REPO\t\t -- already been tapped' $BYELLOW 
}

function check-and-install-brew-repo {
    is-brew-repo-tapped $1 $2 ||   
    msg 'TAPPING\t\t -'$1/$2'- to brew'
    brew tap $1/homebrew-$2 >/dev/null 2>&-
}

function is-cask-package-installed {
    msg 'CHECKING\t\t whether package -'$1'- is installed' $BCYAN    
    brew cask list | grep $1  >/dev/null 2>&- &&
    msg 'SOFTWARE\t\t -'$1'- already installed' $BYELLOW
}


function check-and-cask-install {
    is-cask-package-installed $1 ||
    msg 'SOFTWARE\t\t -'$1'- not install by cask' $BRED &&
    brew cask install $1 > /dev/null 2>&-
}

function install-tmate {
    check-and-install-brew-repo nviennot tmate
    check-and-brew-install tmate
}

function cask-packages-path(){
    brew cask info $1 | sed -n 3p | awk '{split($0,a," "); print a[1]}'
}

function is_rvm_ruby {
  msg 'CHECKING\t\t whether rvm ruby is installed' $BCYAN        
  which ruby | grep rvm
}

function is_gem_installed {
    gem list | grep $1  > /dev/null 2>&-  && 
    msg 'GEM\t\t -'$1'- already been installed' $BYELLOW
}
function install_gem {
    msg 'GEM\t\t -'$1'- not been installed' $BRED
    msg 'INSTALL\t\t gem -'$1'- for you' $BPURPLE
    is_rvm_ruby &&
    gem install -f $1 > /dev/null 2>&- ||
    sudo gem install -f $1 > /dev/null 2>&- 
}

function check-and-gem-install {
    msg 'CHECKING\t\t whether gem -'$1'- is installed' $BCYAN
    is_gem_installed $1  || install_gem $1
}

function cleanup-command {
    msg 'CHECKING\t\t for command -'$1'-'  $BCYAN
    which $1 | xargs sudo rm -rf
}

function install-brew {
    check-command-existence brew &&
    msg 'COMMAND\t\t -brew- has been installed' $BYELLOW ||
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
    msg 'UPDATING\t\t -homebrew-...' $BPURPLE
    brew update > /dev/null 2>&-
}

function install-rvm {
    check-command-existence rvm &&
    msg 'COMMAND\t\t -rvm- has been installed' $BYELLOW ||
    \curl -sSL https://get.rvm.io | bash -s stable --ruby
    msg 'UPDATING\t\t -rvm-...' $BPURPLE
    rvm get stable > /dev/null 2>&-
    source /Users/`whoami`/.rvm/scripts/rvm
}

function alfred-index-brew-cask {
    brew cask alfred link > /dev/null 2>&-
}
function install-brew-cask {
    check-and-install-brew-repo phinze cask
    check-and-brew-install brew-cask
    alfred-index-brew-cask    
}

function setting-git-hub-alias {
    echo 'alias git=hub' >> $SHELL_CONFIG_FILE
}

function install-git {
    check-and-brew-install git
    check-and-brew-install hub
    setting-git-hub-alias
}
function patch-shebang-path() {
    sed -i.bak '1 c\
#\!/usr/bin/env '$2'\
'  $1
rm $1.bak    
}

function install-Inconsolata-powerline-font {
    msg 'INSTALL\t\t patched font for powline theme' $BPURPLE
    check-and-brew-install wget
    wget -q 'https://github.com/Lokaltog/powerline-fonts/blob/master/Inconsolata/Inconsolata%20for%20Powerline.otf' -O Inconsolata\ for\ Powerline.otf
    mv Inconsolata\ for\ Powerline.otf /Library/Fonts/
}

function get-root-permisson {
   #TODO somettime the permission will expired
   sudo ls > /dev/null 2>&-
}

function  install_pow {
    curl get.pow.cx | sh    
}

source /dev/stdin  <<< "$(curl -s https://raw.github.com/ripple0328/mac-install-utils/master/basic-environment-installation.sh)"

