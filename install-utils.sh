#!/usr/bin/env bash

function colors {
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

CURRENT_SHELL=$(echo $SHELL | cut -f3 -d/)
SHELL_CONFIG_FILE=$(echo '.'$CURRENT_SHELL'rc')

if [ ! -f ~/$SHELL_CONFIG_FILE ];
then
    touch ~/$SHELL_CONFIG_FILE
fi    

function setting-cask-install-path {
    cat ~/$SHELL_CONFIG_FILE | grep HOMEBREW_CASK_OPTS ||
    echo 'export HOMEBREW_CASK_OPTS="--appdir=/Applications"' >> ~/$SHELL_CONFIG_FILE
    source ~/$SHELL_CONFIG_FILE 
}

function setting-path {
    # for rvm
    echo $PATH | grep /usr/local/bin &&
    (echo 'export PATH="/usr/local/bin:$PATH"' >> ~/$SHELL_CONFIG_FILE
    source ~/$SHELL_CONFIG_FILE)    
}

function msg {
    printf "$BGREEN 0000===--->$RESET $2 $1 $RESET\n"
}


function check-command-existence {
    msg 'CHECKING\t\t command -'$1'- existences' $BCYAN
    command -v $1 >/dev/null 2>&1
    # hash $1 > /dev/null 2>&1 &&
    msg 'COMMAND\t\t -'$1'- already been installed' $BYELLOW ||
    (msg 'COMMAND\t\t -'$1'- not installed' $BRED
        return 1
    )
}

function is-brew-installed {
    msg 'CHECKING\t\t whether -'$1'- has been installed' $BCYAN    
    brew list | grep $1  > /dev/null 2>&- &&
    msg 'PACKAGE\t\t -'$1'- already been installed' $BYELLOW ||
    (msg 'PACKAGE\t\t -'$1'- not installed' $BRED
        return 1
    )
}

function install-brew-package {
    msg 'INSTALL\t\t -'$1'- by brew' $BPURPLE
    brew install $1 $2  > /dev/null 2>&1
    msg 'LINKING\t\t -'$1'- to system path' $BPURPLE
    brew link --overwrite $1  > /dev/null 2>&1
    msg 'Upgrade\t\t -'$1'-' $BPURPLE
    brew upgrade $1 > /dev/null 2>&1
}

function check-and-brew-install {
    is-brew-installed $1 || install-brew-package $1 $2
}

function is-npm-packages-installed {
    msg 'CHECKING\t\t whether -'$1'- has been installed' $BCYAN    
    npm list -g --parseable | grep $1 > /dev/null 2>&1  &&
    msg 'PACKAGE\t\t -'$1'- already been installed' $BYELLOW ||
    (msg 'PACKAGE\t\t -'$1'- not installed' $BRED
        return 1
    )
}

function install-npm-package {
    msg 'INSTALL\t\t -'$1'- by npm' $BPURPLE
    npm install -g $1 > /dev/null 2>&1
}

function check-and-npm-install {
    is-npm-packages-installed $1 ||
    install-npm-package $1
}

function is-brew-repo-tapped {
    msg 'CHECKING\t\t whether repo -'$1/$2'- has been taped' $BCYAN       
    brew tap | grep $1/$2  >/dev/null 2>&1 &&
    msg 'REPO\t\t -- already been tapped' $BYELLOW 
}

function check-and-install-brew-repo {
    is-brew-repo-tapped $1 $2 ||   
    msg 'TAPPING\t\t -'$1/$2'- to brew'
    brew tap $1/homebrew-$2 >/dev/null 2>&1
}

function is-cask-package-installed {
    msg 'CHECKING\t\t whether package -'$1'- is installed' $BCYAN
    brew cask list | grep `echo $1 | tr '[:upper:]' '[:lower:]'`  >/dev/null 2>&1 &&
    msg 'SOFTWARE\t\t -'$1'- already installed' $BYELLOW
}


function check-and-cask-install {
    is-cask-package-installed $1 ||
    (msg 'SOFTWARE\t\t -'$1'- not install by cask' $BRED 
    msg 'INSTALL\t\t -'$1'-  by cask' $BPURPLE
    brew cask install $1 > /dev/null 2>&1)
}

function install-tmate {
    check-and-install-brew-repo nviennot tmate
    check-and-brew-install tmate
}

function cask-packages-path {
    brew cask info $1 | sed -n 3p | awk '{split($0,a," "); print a[1]}'
}

function is-rvm-ruby {
  msg 'CHECKING\t\t whether rvm ruby is installed' $BCYAN        
  which ruby | grep rvm  > /dev/null 2>&1 
}

function is-gem-installed {
    msg 'CHECKING\t\t whether gem -'$1'- is installed' $BCYAN
    gem list | grep $1  > /dev/null 2>&1  && 
    msg 'GEM\t\t -'$1'- already been installed' $BYELLOW ||
    (msg 'GEM\t\t -'$1'- not been installed' $BRED
     return -1
    )
}
function install-gem {
    msg 'INSTALL\t\t gem -'$1'- for you' $BPURPLE
    is-rvm-ruby && gem install -f $1 > /dev/null 2>&1 ||
    (sudo gem install -f $1 > /dev/null 2>&1)
}

function check-and-gem-install {
    is-gem-installed $1  || install-gem $1
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
    brew update > /dev/null 2>&1
}

function install-rvm {
    check-command-existence rvm &&
    msg 'COMMAND\t\t -rvm- has been installed' $BYELLOW ||
    (\curl -sSL https://get.rvm.io | bash -s stable --ruby
        setting-path)
    msg 'UPDATING\t\t -rvm-...' $BPURPLE
    source /Users/`whoami`/.rvm/scripts/rvm
    rvm get stable > /dev/null 2>&1
    rvm use 2.1 --default
}

function alfred-index-brew-cask {
    brew cask alfred link > /dev/null 2>&1
}
function install-brew-cask {
    is-brew-installed brew-cask ||
    (setting-cask-install-path
    check-and-install-brew-repo phinze cask
    check-and-brew-install brew-cask
    alfred-index-brew-cask)    
}

function setting-git-hub-alias {
    echo 'alias git=hub' >> $SHELL_CONFIG_FILE
    source ~/$SHELL_CONFIG_FILE    
}

function install-git {
    is-brew-installed hub ||
    (setting-git-hub-alias
    check-and-brew-install git
    check-and-brew-install hub)
}

function patch-shebang-path  {
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

function get-root-permission {
   #TODO somettime the permission will expired
   while true;
   do 
       sudo ls /sbin > /dev/null 2>&1 && break;
   done
}

function  install-pow {
    curl get.pow.cx | sh    
}

function install-utils {
    cd ~
    curl -so.install-utils https://raw.github.com/ripple0328/mac-install-utils/master/install-utils.sh
    cat ~/$SHELL_CONFIG_FILE | grep install-utils  > /dev/null 2>&1 ||
    (echo 'source ~/.install-utils' >> ~/$SHELL_CONFIG_FILE
    source ~/$SHELL_CONFIG_FILE)
    source ~/.install-utils
}
