#!/bin/bash

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Use a different prompt char depending on the type of user (root or other)
prompt_char() {
    [ $UID = 0 ] && echo '#' || echo '$'
}

# Let other sourced scripts define an "EXTRA_PS1" environment variable that
# helps adding dynamic data into the prompt without breaking the base prompt
# structure defined here after.
extra_ps1() {
    evaluated_extra_ps1="`eval echo "${EXTRA_PS1}"`"
    echo "$evaluated_extra_ps1${evaluated_extra_ps1:+ }"
}

# Builds the prefix to any PS1 string that will be generated hereafter
prompt_prefix='${debian_chroot:+($debian_chroot)}'

# Builds a colored prompt string for PS1 variable
build_colored_prompt() {
    # Inner function adding escape sequences for colors declared within the PS1
    p_col() { echo '\['${!1}'\]'; }

    printf "$prompt_prefix`p_col BGreen`\\\\u@\\h`p_col NC`: `p_col BYellow`\\w`p_col NC` "
    printf "`p_col BCyan`\$(extra_ps1)`p_col NC``p_col BBlue`\$(prompt_char)`p_col NC` "
}

# Set PS1 prompt string
if [ "$color_prompt" = yes ]; then
    PS1="`build_colored_prompt`"
else
    PS1="$prompt_prefix"'\u@\h: \w $(extra_ps1)$(prompt_char) '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;$prompt_prefix\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

