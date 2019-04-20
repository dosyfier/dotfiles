#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_ubuntu() {
  install_repo jonathonf/vim
  # N.B. vim-gtk is a compiled vim version providing support for system clipboard
  install_packages vim vim-gtk
}

install_winbash() {
  install_ubuntu
}

main "$@"

