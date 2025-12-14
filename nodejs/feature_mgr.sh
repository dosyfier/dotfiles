#!/bin/bash

NVM_VERSION=0.40.3

NODEJS_VERSION=24.11.1

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_common() {
  # Install NVM
  curl -fsSL -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | \
    SHELL=noshell bash

  # Load NVM
  source "$(dirname "$0")/aliases/nodejs.sh"
  load_nvm

  # Install configured Node.js version
  if [ -z "$(nvm ls --no-alias --no-colors 2>/dev/null)" ]; then
    nvm install "$NODEJS_VERSION"
  fi
  nvm use default
}

main "$@"
