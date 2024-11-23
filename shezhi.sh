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
    sudo apt-get install -y git direnv bash-completion tmux powerline curl fish neovim
    # Install pyenv dependencies
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    # Install pyenv
    curl https://pyenv.run | bash
}

function install_mac_pkgs {
    # Install Homebrew if not installed
    which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # Install packages
    NONINTERACTIVE=1 brew install git direnv tmux curl fish pyenv starship neovim
}

function install_pkgs_in_common {
    # install rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # install starship if not installed via package manager
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    git clone --depth 1 --branch v3.1.0 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

function set_up_sudo {
    # set up passwordless sudoer
    SUDOER_DIR="/etc/sudoers.d"
    if $_ismac; then
        SUDOER_DIR="/private/etc/sudoers.d"
    fi
    echo -e "\n$USER ALL=(ALL) NOPASSWD: ALL\n" > $USER
    sudo mv $USER $SUDOER_DIR/
    sudo chmod -w $SUDOER_DIR/$USER
    sudo chown root:root $SUDOER_DIR/$USER
}

function config {
    # set up bash
    [[ -f $HOME/.bashrc ]] && mv $HOME/.bashrc $HOME/.bashrc.bak
    ln -sf $SHEZHI_DIR/bashrc $HOME/.bashrc

    # set up tmux
    [[ -e $HOME/.tmux.conf ]] && mv $HOME/.tmux.conf $HOME/.tmux.conf.bak
    ln -sf $SHEZHI_DIR/tmux.conf $HOME/.tmux.conf
    [[ -e $HOME/.tmux ]] && mv $HOME/.tmux $HOME/.tmux.bak
    ln -sf $SHEZHI_DIR/tmux $HOME/.tmux

    # set up fish
    mkdir -p $HOME/.config/fish
    [[ -e $HOME/.config/fish/config.fish ]] && mv $HOME/.config/fish/config.fish $HOME/.config/fish/config.fish.bak
    ln -sf $SHEZHI_DIR/config.fish $HOME/.config/fish/config.fish
    
    # set fish as default shell
    if $_ismac; then
        FISH_PATH="/opt/homebrew/bin/fish"
    else
        FISH_PATH="/usr/bin/fish"
    fi
    
    if [ "$SHELL" != "$FISH_PATH" ]; then
        if ! grep -q "$FISH_PATH" /etc/shells; then
            echo "$FISH_PATH" | sudo tee -a /etc/shells
        fi
        chsh -s "$FISH_PATH"
    fi

    # set up direnv
    [[ -e $HOME/.direnvrc ]] && mv $HOME/.direnvrc $HOME/.direnvrc.bak
    ln -sf $SHEZHI_DIR/direnvrc $HOME/.direnvrc

    # set up starship
    mkdir -p $HOME/.config
    [[ -e $HOME/.config/starship.toml ]] && mv $HOME/.config/starship.toml $HOME/.config/starship.toml.bak
    ln -sf $SHEZHI_DIR/starship.toml $HOME/.config/starship.toml

    # set up git
    [[ -e $HOME/.gitconfig ]] && mv $HOME/.gitconfig $HOME/.gitconfig.bak
    ln -sf $SHEZHI_DIR/gitconfig $HOME/.gitconfig

    # set up pyenv
    mkdir -p $HOME/.pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

if $_isubuntu; then
    install_ubuntu_pkgs
elif $_ismac; then
    install_mac_pkgs
else
    echo "unsported system"
    exit 1
fi
install_pkgs_in_common
config
# set_up_sudo
