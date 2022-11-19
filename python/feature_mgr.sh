#!/bin/bash

PYTHON_VERSION="3.11.0"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
}

install_common() {
  # Install PyEnv
  curl https://pyenv.run | bash

  # Setup a Python Virtualenv
  if ! pyenv virtualenvs --bare | grep -q '^default$'; then
    "$HOME/.pyenv/bin/pyenv" virtualenv "$PYTHON_VERSION" "default"
  fi

  # Install Pylint
  pip install pylint

  # Deploy Pylint config file
  [ -e "$HOME"/.pylintrc ] && rm -vf "$HOME"/.pylintrc
  ln -vs "$FEATURE_ROOT"/conf/pylintrc "$HOME"/.pylintrc
}

get_resources() {
  _get_installed_resource \
    "$HOME/.pylintrc" \
    "$HOME/.config/pip/pip.conf"
}

main "$@"
