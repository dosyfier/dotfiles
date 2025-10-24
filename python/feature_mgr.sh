#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

PYTHON_VERSION="3.11.14"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
}

install_common() {
  # Install PyEnv
  curl -sSfL https://pyenv.run | bash

  # Load PyEnv
  source "$(dirname "$0")/aliases/pyenv.sh"
  load_py

  # Setup a Python Virtualenv
  if ! pyenv virtualenvs --bare | grep -q '^default$'; then
    pyenv install "$PYTHON_VERSION"
    pyenv virtualenv "$PYTHON_VERSION" "default"
  fi
  pyenv activate default

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

update() {
  git -C "$HOME"/.pyenv pull
}

main "$@"
