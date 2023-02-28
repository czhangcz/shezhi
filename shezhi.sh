#!/bin/bash

set -ex

_islinux=false
[[ "$(uname -s)" =~ Linux|GNU|GNU/* ]] && _islinux=true

_isubuntu=false
$_islinux && [[ -f /etc/lsb-release ]] && _isubuntu=true

_ismac=false
! $_islinux && [[ `uname` == "Darwin" ]] && _ismac=true

if ! $_ismac && ! $_isubuntu ; then
    echo "unsported system"
    exit 1
fi

SHEZHI_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install_ubuntu_pkgs {
    sudo apt update
    sudo apt-get install -y git direnv bash-completion tmux powerline
}

function install_mac_pkgs {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    NONINTERACTIVE=1 brew install git direnv bash-completion tmux powerline
}

# set up passwordless sudoer
SUDOER_DIR="/etc/sudoers.d"
if $_ismac; then
    SUDOER_DIR="/private/etc/sudoers.d"
fi
echo -e "\n$USER ALL=(ALL) NOPASSWD: ALL\n" > $USER
sudo mv $USER $SUDOER_DIR/
sudo chmod -w $SUDOER_DIR/$USER
sudo chown root:root $SUDOER_DIR/$USER

if $_isubuntu; then
    install_ubuntu_pkgs
else
    install_mac_pkgs
fi

# set up bash
[[ -f $HOME/.bashrc ]] && mv $HOME/.bashrc $HOME/.bashrc.bak
ln -s $SHEZHI_DIR/bashrc $HOME/.bashrc

# set up tmux
[[ -e $HOME/.tmux.conf ]] && mv $HOME/.tmux.conf $HOME/.tmux.conf.bak
ln -s $SHEZHI_DIR/tmux.conf $HOME/.tmux.conf
ln -s $SHEZHI_DIR/tmux $HOME/.tmux