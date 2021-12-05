#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if [ "$(vim --version | grep -E '[0-9]+' -o -m 1 | head -n 1)" -lt 8 ]; then
    echo "vim"
  fi
  if ! command -v npm > /dev/null; then
    echo "nodejs"
  fi
}

install_centos() {
  _install
}

install_wsl() {
  _install
}

_install() {
  # Install SpaceVim
  curl -sLf https://spacevim.org/install.sh | bash

  # Link config folder to the Dobashconfig-managed folder
  [ -e "$HOME"/.SpaceVim.d ] && rm -rvf "$HOME"/.SpaceVim.d
  ln -vs "$FEATURE_ROOT"/conf "$HOME"/.SpaceVim.d

  # Install prerequisites for SpaceVim tags database management
  # See: https://spacevim.org/layers/gtags/ 
  install_packages global exuberant-ctags

  # Install prerequisites for Python language
  install_packages python3
  sudo env pip3 install pylint yapf autoflake isort
  sudo npm install -g pyright
}

main "$@"

