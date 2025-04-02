# ~/.zshrc

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.

# set editor and pager
export EDITOR="vim"
export PAGER="less -FirSwX"
export MANPAGER="$PAGER"

# Colors
autoload -U colors && colors

# Basic auto/tab completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)   # Include hidden files

# Enable ls colors
if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi

# Common aliases
alias ll='ls -lF'
alias la='ls -A'
alias l='ls -CF'
alias vi='vim'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Terminal
export TERM=xterm-256color

# Set up pyenv
export PATH="${HOME}/bin:$PATH"
eval "$(direnv hook zsh)"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Set up paths
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/local/bin:$PATH"

# Initialize starship prompt if installed
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Load local config if exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
