#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_wsl() {
  install_ubuntu
}

install_ubuntu() {
  curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

main "$@"

