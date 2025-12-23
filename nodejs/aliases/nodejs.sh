#!/bin/bash

# Node JS shell aliases

load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091 # Source can't be followed
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  # shellcheck disable=SC1091 # Source can't be followed
  [ -s "$NVM_DIR/bash_completion" ] && [ "$CURRENT_SHELL" = bash ] && \. "$NVM_DIR/bash_completion"
}
