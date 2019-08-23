#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  echo cabal
}

install_centos() {
  _install
}

install_redhat() {
  _install
}

install_ubuntu() {
  _install
}

install_wsl() {
  _install
}

_install() {
  if command -v shellcheck > /dev/null 2>&1; then
    echo "ShellCheck is already installed. Skipping."
  else
    # shellcheck disable=SC2033
    # SC2033: We are not passing the 'install' command to cabal, just an argument
    sudo cabal install --global ShellCheck 
  fi
}

main "$@"

