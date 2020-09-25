#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  install_packages ruby
  _install_gems
}

install_redhat() {
  install_centos
}

install_ubuntu() {
  install_repo brightbox/ruby-ng
  install_packages ruby ruby-dev
  _install_gems
}

install_wsl() {
  install_ubuntu
}

_install_gems() {
  sudo gem install \
    solargraph \
    chef \
    knife \
    rspec \
    rubocop \
    rake \
    rdoc \
    pry
}

main "$@"

