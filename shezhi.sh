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

function show_usage {
    echo "Usage: shezhi.sh [OPTIONS]"
    echo "Set up development environment with chosen shell and tools"
    echo ""
    echo "Options:"
    echo "  --shell SHELL   Choose shell to install (fish or zsh, default: fish)"
    echo "  --help          Show this help message and exit"
    exit 0
}

SHELL_CHOICE="fish"  # Default shell choice
while [[ $# -gt 0 ]]; do
    case $1 in
        --shell)
            SHELL_CHOICE="$2"
            shift 2
            ;;
        --help)
            show_usage
            ;;
        *)
            shift
            ;;
    esac
done

if [[ "$SHELL_CHOICE" != "fish" && "$SHELL_CHOICE" != "zsh" ]]; then
    echo "Invalid shell choice. Please use --shell with either 'fish' or 'zsh'"
    exit 1
fi

function install_ubuntu_pkgs {
    sudo apt update
    sudo apt-get install -y git direnv bash-completion tmux curl neovim
    # Install shell of choice
    echo "Installing $SHELL_CHOICE" 
    if [ "$SHELL_CHOICE" = "fish" ]; then
        sudo apt-get install -y fish
    else
        sudo apt-get install -y zsh
    fi
    # Install pyenv dependencies
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    # Install pyenv
    if [ -d "$HOME/.pyenv" ]; then
        echo "Existing pyenv installation found. Removing it..."
        rm -rf "$HOME/.pyenv"
    fi
    curl https://pyenv.run | bash
}

function install_mac_pkgs {
    # Install Homebrew if not installed
    which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    # Install packages
    if [ -d "$HOME/.pyenv" ]; then
        echo "Existing pyenv installation found. Removing it..."
        rm -rf "$HOME/.pyenv"
    fi
    NONINTERACTIVE=1 brew install git direnv tmux curl pyenv starship neovim
    # Install shell of choice
    if [ "$SHELL_CHOICE" = "fish" ]; then
        NONINTERACTIVE=1 brew install fish
    else
        NONINTERACTIVE=1 brew install zsh
    fi
}

function install_pkgs_in_common {
    # install rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # install starship if not installed via package manager
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # install uv
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # install tmux plugins
    [[ -e $HOME/.tmux ]] && mv $HOME/.tmux $HOME/.tmux.bak
    mkdir -p ~/.tmux/plugins
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

    # set up shell of choice
    if [ "$SHELL_CHOICE" = "fish" ]; then
        # set up fish
        mkdir -p $HOME/.config/fish
        [[ -e $HOME/.config/fish/config.fish ]] && mv $HOME/.config/fish/config.fish $HOME/.config/fish/config.fish.bak
        ln -sf $SHEZHI_DIR/config.fish $HOME/.config/fish/config.fish
    else
        # set up zsh
        [[ -e $HOME/.zshrc ]] && mv $HOME/.zshrc $HOME/.zshrc.bak
        ln -sf $SHEZHI_DIR/zshrc $HOME/.zshrc
    fi
    
    # set chosen shell as default
    if [ "$SHELL_CHOICE" = "fish" ]; then
        if $_ismac; then
            SHELL_PATH="/opt/homebrew/bin/fish"
        else
            SHELL_PATH="/usr/bin/fish"
        fi
    else
        if $_ismac; then
            SHELL_PATH="/opt/homebrew/bin/zsh"
        else
            SHELL_PATH="/usr/bin/zsh"
        fi
    fi
    
    if [ "$SHELL" != "$SHELL_PATH" ]; then
        if ! grep -q "$SHELL_PATH" /etc/shells; then
            echo "$SHELL_PATH" | sudo tee -a /etc/shells
        fi
        chsh -s "$SHELL_PATH"
    fi

    # set up tmux
    [[ -e $HOME/.tmux.conf ]] && mv $HOME/.tmux.conf $HOME/.tmux.conf.bak
    ln -sf $SHEZHI_DIR/tmux.conf $HOME/.tmux.conf

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
    if [ ! -d "$HOME/.pyenv" ]; then
        mkdir -p $HOME/.pyenv
    fi
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

function show_help {
    echo "Shezhi - Development Environment Setup Tool"
    echo ""
    echo "This script helps you set up a development environment on Ubuntu or macOS systems."
    echo "It installs and configures:"
    echo "  - Shell (fish or zsh)"
    echo "  - Git with configuration"
    echo "  - Tmux with plugins"
    echo "  - Pyenv for Python version management"
    echo "  - Direnv for environment management"
    echo "  - Starship prompt"
    echo "  - Rust via rustup"
    echo "  - Neovim editor"
    echo ""
    echo "The script will create backup files for any existing configurations"
    echo "before creating symbolic links to the new configuration files."
    echo ""
    echo "To activate tmux plugins, press prefix + I in a tmux session."
}

install_pkgs_in_common
config
# set_up_sudo
show_help
