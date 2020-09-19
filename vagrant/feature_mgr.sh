#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

VAGRANT_VERSION=2.2.5

# -- Per-distro install functions

install_centos() {
  _install
}

install_ubuntu() {
  _install_deb_from_website
}

install_wsl() {
  _install_deb_from_website
}

# -- Internal functions

_install() {
  install_packages vagrant
}

_install_deb_from_website() {
  sudo curl -L https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb \
    -o /var/cache/apt/archives/vagrant_${VAGRANT_VERSION}_x86_64.deb
  sudo apt-get install /var/cache/apt/archives/vagrant_${VAGRANT_VERSION}_x86_64.deb
}

# -- Main

main "$@"

