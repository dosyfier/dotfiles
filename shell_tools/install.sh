#!/bin/bash

source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  _install
}

install_redhat() {
  _install
}

install_ubuntu() {
  _install
}

install_winbash() {
  _install
}

_install() {
  install_packages rsync tmux tree
}

# shellcheck disable=SC2068
# Unquoted array expansion is here expected
main $@

