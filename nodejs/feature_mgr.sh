#!/bin/bash

NVM_VERSION=0.40.3

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_common() {
  curl -fsSL -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | \
    SHELL=noshell bash
}

main "$@"
