#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git > /dev/null; then
    echo "git"
  fi
}

install_centos() {
  install_packages make ncurses ncurses-devel
  _compile
}

install_ubuntu() {
  install_repo jonathonf/vim
  # N.B. vim-gtk is a compiled vim version providing support for system clipboard
  install_packages vim vim-gtk
}

install_winbash() {
  install_ubuntu
}

_compile() {
  if [ ! -d /usr/local/src/vim ]; then
    sudo git clone https://github.com/vim/vim /usr/local/src/vim
  fi
  pushd "/usr/local/src/vim" > /dev/null
  trap "popd > /dev/null" EXIT
  if [ -d .git ]; then
    sudo git checkout v8.1.1198
    sudo rm -rf .git
  fi
  sudo make
  sudo make install
}

main "$@"

