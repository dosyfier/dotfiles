#!/bin/bash

current_shell() {
  # Based on https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#answer-3327022
  if [ -v version ]; then
    echo tcsh
  elif [ -v BASH ]; then
    echo bash
  elif [ -v ZSH_NAME ]; then
    echo zsh
  elif [ -v PS4 ]; then
    echo ksh
  elif [ -v shell ]; then
    echo "$shell"
  elif [ -v SHELL ]; then
    echo "$SHELL"
  else
    echo "Unknown shell" >&2
    exit 1
  fi
}

# Save once and for all the name of the current shell (which should
# remain the same for the current shell session, hopefully!)
CURRENT_SHELL="$(current_shell)"

if [ "$CURRENT_SHELL" = bash ]; then
  # check the window size after each command and, if necessary,
  # update the values of LINES and COLUMNS.
  shopt -s checkwinsize

  # If set, the pattern "**" used in a pathname expansion context will
  # match all files and zero or more directories and subdirectories.
  shopt -s globstar
  
  # If set, Bash replaces directory names with the results of word 
  # expansion when performing filename completion. This changes the 
  # contents of the readline editing buffer.
  shopt -s direxpand
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# some ls aliases
alias ll='ls -lF --group-directories-first'
alias la='ls -A --group-directories-first'
alias l='ls -CF --group-directories-first'
alias lla='ll -a'
alias lh='ll -h'

# Add an "alert" alias for long running commands. Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low '\
'-i "$([ $? = 0 ] && echo terminal || echo error)" '\
'"$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Add $HOME/.local/bin to $PATH when suitable
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  PATH="$HOME/.local/bin:$PATH"
fi
