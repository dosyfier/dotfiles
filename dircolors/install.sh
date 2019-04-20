#!/bin/bash

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(realpath "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

install_ubuntu() {
  install_packages dircolors
  ln -s "$FEATURE_ROOT"/config.dircolors "$HOME"/.dircolors
}

install_winbash() {
  install_ubuntu
}

main "$@"

