#!/bin/bash

COMPREPLY=()

_script_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${COMP_CWORD} -eq 1 ]; then
        COMPREPLY=( $(compgen -f $cur) )
    else
        COMPREPLY=()
    fi
}

complete -F _script_completion "./addimage.sh"