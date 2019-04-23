#!/bin/bash

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(realpath "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  install_packages coreutils
  _configure
}

install_ubuntu() {
  install_packages dircolors
  _configure
}

install_winbash() {
  install_ubuntu
}

_configure() {
  ln -s "$FEATURE_ROOT"/config.dircolors "$HOME"/.dircolors
}

main "$@"

