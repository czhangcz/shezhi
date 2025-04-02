# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
#HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
#HISTSIZE=1000
#HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# get current git branch name
function git_branch {
    export gitbranch=[$(git rev-parse --abbrev-ref HEAD 2>/dev/null)]
    if [ "$?" -ne 0 ]
      then gitbranch=
    fi
    if [[ "${gitbranch}" == "[]" ]]
      then gitbranch=
    fi
}

# set editor and pager
EDITOR="vim"
export EDITOR

PAGER="less -FirSwX"
MANPAGER="$PAGER"
export PAGER MANPAGER

# set usercolor based on whether we are running with Admin privs
function user_color {
    id | grep "Admin" > /dev/null
    RETVAL=$?
    if [[ $RETVAL == 0 ]]; then
        usercolor="[0;35m";
    else
        usercolor="[0;32m";
    fi
}

# set TTYNAME
function ttyname() { export TTYNAME=$@; }

# Set prompt and window title
inputcolor='[0;37m'
cwdcolor='[0;34m'
gitcolor='[1;31m'
user_color

# Setup for window title
export TTYNAME=$$
function settitle() {
  p=$(pwd);
  let l=${#p}-25
  if [ "$l" -gt "0" ]; then
    p=..${p:${l}}
  fi
  t="$TTYNAME $p"
  echo -ne "\e]2;$t\a\e]1;$t\a";
}

PROMPT_COMMAND='settitle; git_branch; history -a;'
export PS1='\[\e${usercolor}\][\u]\[\e${gitcolor}\]${gitbranch}\[\e${cwdcolor}\][$PWD]\[\e${inputcolor}\] $ '

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -lF'
alias la='ls -A'
alias l='ls -CF'
alias vi='vim'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Use bash-completion, if available
if [[ `uname` == "Darwin" ]]; then
  [[ $PS1 &&  -f /usr/local/etc/bash_completion ]] && . /usr/local/etc/bash_completion
else
  [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
fi

#source /usr/local/bin/virtualenvwrapper.sh
export TERM=xterm-256color

# Set up pyenv
export PATH="${HOME}/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/local/bin:$PATH"
eval "$(direnv hook bash)"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"
# export KUBECONFIG=$(ls -a ~/.kube/*.conf | paste -sd ":" -)

# source <(kubectl completion bash)
# source /home/chongzha/local/lib/kubectx/completion/kubectx.bash
# source /home/chongzha/local/lib/kubectx/completion/kubens.bash
# source <(kops completion bash)
# source <(argo completion bash)

## General environment variables
# complete -C /home/chongzha/local/bin/terraform_0.12.6 terraform_0.12.6
