#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_ubuntu() {
  install_repo jonathonf/vim
  install_packages vim
}

install_winbash() {
  install_ubuntu
}

main "$@"

