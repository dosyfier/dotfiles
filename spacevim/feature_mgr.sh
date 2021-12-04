#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if [ "$(vim --version | grep -E '[0-9]+' -o -m 1 | head -n 1)" -lt 8 ]; then
    echo "vim"
  fi
}

install_centos() {
  _install
}

install_wsl() {
  _install
}

_install() {
  curl -sLf https://spacevim.org/install.sh | bash

  [ -e "$HOME"/.SpaceVim.d ] && rm -rvf "$HOME"/.SpaceVim.d
  ln -vs "$FEATURE_ROOT"/conf "$HOME"/.SpaceVim.d

  install_packages global ctags

  # Python
  install_packages python3
  sudo env pip3 install pylint yapf autoflake isort
  sudo npm install -g pyright
}

main "$@"

