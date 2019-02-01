# prompt and tmux pane title {{{
function __prompt_command {
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # color support
        c_project="$(tput setaf 3)"
        c_reset="$(tput sgr0)"
    fi
    if [ -n "$PROJECT" ]; then
        PS1="${c_project}[$PROJECT]${c_reset}:\w\$ "
        pane_title="[$PROJECT]:$PWD"
    else
        PS1="\u@\h:\w\$ "
        pane_title="$PWD"
    fi
    [ -n "TMUX_PANE" ] && printf '\033]2;%s\033\\' "$pane_title"
}
PROMPT_COMMAND=__prompt_command
# }}}

# project aliases and functions {{{
alias cdp='cd "$PROJECT_ROOT"'
alias cdb='cd "$PROJECT_ROOT/build"'

function project {
    source "$HOME/projects/$1/.env"
}
# }}}

export EDITOR=vim

# vim:set foldmethod=marker:
