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
  # Install GCC (needed to compile Python)
  # TODO: Only valid for Fedora 22+. Do it for others! See: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  install_packages make gcc patch zlib-devel bzip2 bzip2-devel readline-devel \
    sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2

  # Install PyEnv
  if ! [ -d "$HOME/.pyenv" ]; then
    curl -sSfL https://pyenv.run | bash
  fi

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
