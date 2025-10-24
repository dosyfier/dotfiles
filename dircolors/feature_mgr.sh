#!/bin/bash

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

install_common() {
  install_packages coreutils
  _configure
}

_configure() {
  [ -e "$HOME"/.dircolors ] && rm -vf "$HOME"/.dircolors
  ln -vs "$FEATURE_ROOT"/config.dircolors "$HOME"/.dircolors
}

get_resources() {
  _get_installed_resource "$HOME/.dircolors"
}

main "$@"

