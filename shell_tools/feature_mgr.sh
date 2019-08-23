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

install_wsl() {
  _install
}

_install() {
  install_packages rsync tmux tree
}

main "$@"

