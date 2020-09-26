#!/bin/bash

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

install_redhat() {
  install_packages coreutils
  _configure
}

install_centos() {
  install_packages coreutils
  _configure
}

install_ubuntu() {
  install_packages coreutils
  _configure
}

install_wsl() {
  install_ubuntu
}

_configure() {
  [ -e "$HOME"/.dircolors ] && rm -vf "$HOME"/.dircolors
  ln -vs "$FEATURE_ROOT"/config.dircolors "$HOME"/.dircolors
}

main "$@"

