#!/bin/bash

source "$(dirname "$0")/../internal/install-base.sh"

install_ubuntu() {
  install_repo jonathonf/vim
  install_packages vim
}

install_winbash() {
  install_ubuntu
}

# shellcheck disable=SC2068
# Unquoted array expansion is here expected
main $@

