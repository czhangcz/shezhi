# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Shezhi is a personal dotfiles and development environment setup repository that automates the configuration of development tools across Linux (Ubuntu) and macOS systems. The repository uses a flat structure with all configuration files at the root level and a single setup script that orchestrates the entire installation and configuration process.

## Key Commands

### Setup and Installation
```bash
# Run main setup with Fish shell (default)
./shezhi.sh

# Run setup with Zsh instead of Fish
./shezhi.sh --shell zsh

# Show help and available options
./shezhi.sh --help
```

### Development Workflow
```bash
# Test configuration changes (after editing dotfiles)
source ~/.bashrc    # For bash changes
source ~/.zshrc     # For zsh changes
# Or open new terminal session

# Install Tmux plugins after setup
# In tmux session: Ctrl+A, then Shift+I

# Check git configuration
git config --list

# Verify pyenv installation
pyenv versions
```

## Architecture

### Core Components

1. **shezhi.sh**: Main orchestration script with four phases:
   - OS detection (Linux/Ubuntu vs macOS)
   - Package installation (system packages via apt/brew)
   - Common tool installation (Rust, Python, Starship, etc.)
   - Configuration linking (symlinks dotfiles to home directory)

2. **Shell Configurations**: Support for three shells with consistent tooling:
   - `bashrc`: Custom prompt with git branch detection
   - `zshrc`: Modern zsh config with tab completion
   - `config.fish`: Minimal Fish configuration with Starship

3. **Tool Configurations**:
   - `gitconfig`: Custom log aliases (los, lol, tree)
   - `tmux.conf`: Prefix Ctrl+A, vi-mode, plugin management via TPM
   - `starship.toml`: Universal prompt with git and language detection
   - `wezterm.win.lua`: Windows WSL terminal configuration

### Configuration Strategy

All dotfiles are stored in the repository and symlinked to standard locations (`~/.bashrc`, `~/.gitconfig`, etc.). Existing files are backed up with `.bak` suffix. This allows central management and version control of all configurations.

### Tool Integration

- **Shell Enhancement**: All shells integrate pyenv, direnv, and Starship prompt
- **Terminal Multiplexing**: Tmux with plugin system (sensible, resurrect, power theme)
- **Development Tools**: Git, Neovim, Rust/Cargo, Python via pyenv, UV package manager
- **Environment Management**: Direnv for project-specific environments

## Git Remote

This repo uses the `githubcz` SSH host alias (defined in `~/.ssh/config`) to authenticate with the correct personal GitHub key (`~/.ssh/id_ed25519_cz`). The remote URL should be `git@githubcz:czhangcz/shezhi.git`, not `git@github.com:...`.

## Important Notes

- The setup script requires `set -ex` (exit on error, show commands)
- Only supports Ubuntu Linux and macOS (exits on unsupported systems)
- Uses non-interactive installation flags (`-y`, `NONINTERACTIVE=1`)
- Shell selection affects both installation and default shell configuration
- Tmux plugins require manual activation after setup (Ctrl+A + Shift+I)

## File Modifications

When editing configurations:
- Modify files in the repository root (they are symlinked)
- Changes to shell configs require sourcing or new terminal session
- Tmux config changes require tmux server restart or reload
- Git changes are immediately effective

When adding new tools:
- Add installation commands to appropriate functions in `shezhi.sh`
- Add configuration files to repository root
- Update the `config()` function to create necessary symlinks