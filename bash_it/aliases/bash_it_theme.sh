#!/bin/bash

# shellcheck disable=SC1091  # Can't point to sh scripts sourced from Bash-it / Gitstatus

export BASH_IT=/opt/bash-it

if [ -d /opt/gitstatus ]; then
  export SCM_GIT_USE_GITSTATUS=true
  source /opt/gitstatus/gitstatus.plugin.sh
  gitstatus_stop && gitstatus_start
fi

_command_exists() {
  type "$1" &> /dev/null;
}

# For setup details, check https://bash-it.readthedocs.io/en/latest/themes-list/powerline-base/
export POWERLINE_PROMPT="
  hostname
  clock
  user_info
  scm
  python_venv
  ruby
  cwd
"
export CLOCK_THEME_PROMPT_COLOR=${POWERLINE_CLOCK_COLOR:=36}

source "$BASH_IT/themes/base.theme.bash"
source "$BASH_IT/themes/colors.theme.bash"
source "$BASH_IT/themes/githelpers.theme.bash"
source "$BASH_IT/themes/powerline/powerline.theme.bash"

function __powerline_cwd_prompt {
  echo "\\w|${CWD_THEME_PROMPT_COLOR}"
}
