#!/bin/bash

EXTERNAL_PROMPT_ENABLED=true
BASH_IT=/opt/bash-it

_command_exists() {
  type "$1" &> /dev/null;
}
source "$BASH_IT/themes/base.theme.bash"
source "$BASH_IT/themes/colors.theme.bash"
source "$BASH_IT/themes/githelpers.theme.bash"
source "$BASH_IT/themes/powerline/powerline.theme.bash"

