#!/bin/bash

# Restrict Bash directory prompt to only the last 4 directory names
PROMPT_DIRTRIM=4

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Builds the prefix to any PS1 string that will be generated hereafter
# shellcheck disable=SC2016
# SC2016: It is here intended not to expand $debian_chroot
prompt_prefix='${debian_chroot:+($debian_chroot)}'

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1_XTERM_PREFIX="\[\e]0;$prompt_prefix\u@\h: \w\a\]"
    ;;
  *)
    ;;
esac

# If a bash prompt is defined by a theme external to dotbashconfig (e.g. Bash-It's Powerline),
# then this alias script is ignored
if [ "$EXTERNAL_PROMPT_ENABLED" = true ]; then
  return
fi

# ------------

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
  evaluated_extra_ps1="$(eval echo "${EXTRA_PS1}")"
  echo "$evaluated_extra_ps1${evaluated_extra_ps1:+ }"
}

# Builds a colored prompt string for PS1 variable
build_colored_prompt() {
  # Inner function adding escape sequences for colors declared within the PS1
  p_col() { echo '\['"${!1}"'\]'; }

  printf "%s%s\\\\u@\\h%s: %s\\w%s " "$prompt_prefix" "$(p_col BGreen)" "$(p_col NC)" "$(p_col BYellow)" "$(p_col NC)"
  printf "%s\$(extra_ps1)%s%s\$(prompt_char)%s " "$(p_col BCyan)" "$(p_col NC)" "$(p_col BBlue)" "$(p_col NC)"
}

# Set PS1 prompt string
if [ "$color_prompt" = yes ]; then
  PS1="$(build_colored_prompt)"
else
  PS1="$prompt_prefix"'\u@\h: \w $(extra_ps1)$(prompt_char) '
fi
unset color_prompt force_color_prompt

if [ -n "$PS1_XTERM_PREFIX" ]; then
  PS1="${PS1_XTERM_PREFIX}${PS1}"
fi

# Use ANSI in PS1 environment variable to notify ConEmu about directory changes
# (e.g. to update tab's title) and prompt end
# Source: https://conemu.github.io/en/ShellWorkDir.html
# shellcheck disable=SC2154
# SC2154: ConEmuPID is a global variable that may be set by another program (ConEmu)
if [ -n "$ConEmuPID" ]; then
  PS1="$PS1\[\e]9;9;\"\w\"\007\e]9;12\007\]"
fi

