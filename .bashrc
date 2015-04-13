# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# command prompt {{{
# A colorized version of __git_ps1
function __git_ps1_color {
    status=$(git status --porcelain 2> /dev/null)
    if $(echo "$status" | egrep "^\?\?" > /dev/null); then
        tput setaf 1 # red: changes not in index
    elif $(echo "$status" | egrep "^\w?A|M|D" > /dev/null); then
        tput setaf 2 # green: changes in index
    fi
}

# TODO: use PROMPT_COMMAND instead?
function build_ps1 {
    local user_and_project="$USER"
    [ -n "$PROJECT" ] && user_and_project="$USER#$PROJECT"

    # set the title
    case "$TERM" in
    xterm*|rxvt*)
        echo -en "\033]2;$user_and_project: $(basename $(pwd))\007"
        ;;
    *)
        ;;
    esac

    # user or user#project_name
    tput bold
    tput setaf 3
    echo -n "$user_and_project"

    tput setaf 4
    echo -n ":$(pwd)"
    tput sgr0

    echo -n "$(__git_ps1_color)$(__git_ps1)$(tput sgr0)\$ "
}

if ! tput setaf 1 >&/dev/null; then
    # no color support
    PS1='\u@\h:\w\$ '
else
    PS1='$(build_ps1)'
fi
# }}}

# project aliases and functions {{{
alias cdp='cd $PROJECT_ROOT'
alias cdb='cd $PROJECT_ROOT/build'

function project {
    source $HOME/projects/$1/.env
}
# }}}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

source /etc/bash_completion.d/git-prompt
export EDITOR=vim

# vim:set foldmethod=marker:
