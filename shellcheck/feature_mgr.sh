#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  _install
}

install_redhat() {
  _install
}

install_ubuntu() {
  _install
}

install_winbash() {
  _install
}

_install() {
  if command -v shellcheck > /dev/null 2>&1; then
    echo "ShellCheck is already installed. Skipping."
  else
    install_packages cabal-install
    cabal update
    # shellcheck disable=SC2033
    # SC2033: We are not passing the 'install' command to cabal, just an argument
    sudo cabal install --global ShellCheck 
    sudo ln -s /usr/local/bin/shellcheck /usr/bin/shellcheck
  fi
}

main "$@"

