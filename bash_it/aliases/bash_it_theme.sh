#!/bin/bash

BASH_IT=/opt/bash-it
if ! [ -d "$BASH_IT" ]; then
  return
fi

EXTERNAL_PROMPT_ENABLED=true

if [ -d /opt/gitstatus ]; then
  SCM_GIT_USE_GITSTATUS=true
  source /opt/gitstatus/gitstatus.plugin.sh
  gitstatus_start
fi

_command_exists() {
  type "$1" &> /dev/null;
}

source "$BASH_IT/themes/base.theme.bash"
source "$BASH_IT/themes/colors.theme.bash"
source "$BASH_IT/themes/githelpers.theme.bash"
source "$BASH_IT/themes/powerline/powerline.theme.bash"

# Restrict Bash directory prompt to only the last 4 directory names
PROMPT_DIRTRIM=4

function __powerline_cwd_prompt {
  echo "\\w|${CWD_THEME_PROMPT_COLOR}"
}

