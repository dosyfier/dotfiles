#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_common() {
  # TODO Install Python, Pylint

  # Deploy Pylint config file
  [ -e "$HOME"/.pylintrc ] && rm -vf "$HOME"/.pylintrc
  ln -vs "$FEATURE_ROOT"/conf/pylintrc "$HOME"/.pylintrc
}

main "$@"
