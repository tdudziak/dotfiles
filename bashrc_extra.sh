# prompt and tmux pane title {{{
function __update_tmux_pane {
    pane_title=""
    if [ -n "$TMUX_PANE" ]; then
        [ -n "$PROJECT" ] && pane_title="[$PROJECT]:"
        pane_title+="$PWD"
        [ -n "$1" ] && pane_title+=" ($1)"
        printf '\033]2;%s\033\\' "$pane_title"
    fi
}

function __prompt_command {
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # color support
        c_project="\[$(tput setaf 3)\]"
        c_reset="\[$(tput sgr0)\]"
    fi
    if [ -n "$PROJECT" ]; then
        PS1="${c_project}[$PROJECT]${c_reset}:\w\$ "
    else
        PS1="\u@\h:\w\$ "
    fi
    __update_tmux_pane
}
PROMPT_COMMAND=__prompt_command
# }}}

# project aliases and functions {{{
alias cdp='cd "$PROJECT_ROOT"'
alias cdb='cd "$PROJECT_ROOT/build"'

function project {
    source "$HOME/projects/$1/.env"
    export PROJECT
    export PROJECT_ROOT
}
# }}}

[ -n "$PROJECT" ] && source "$HOME/projects/$PROJECT/.env"
export EDITOR=vim

# vim:set foldmethod=marker:
