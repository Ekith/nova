# Completion for nova.sh
_nova_completion() {
    # Ensure bash-completion functions are loaded
    if ! type _command_offset >/dev/null 2>&1; then
        [ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
    fi

    if type _command_offset >/dev/null 2>&1; then
        _command_offset 1
    else
        # Fallback if bash-completion is not available
        local cur=${COMP_WORDS[COMP_CWORD]}
        if [ $COMP_CWORD -eq 1 ]; then
            COMPREPLY=( $(compgen -c -- "$cur") )
        else
            COMPREPLY=( $(compgen -f -- "$cur") )
        fi
    fi
}

# Register the completion for both the script and a possible alias/command
complete -F _nova_completion nova.sh nova
