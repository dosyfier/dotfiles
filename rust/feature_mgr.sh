#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_ubuntu() {
  _install
}

install_wsl() {
  _install
}

_install() {
  curl https://sh.rustup.rs -sSf | sh -s - -y --no-modify-path
}

main "$@"
