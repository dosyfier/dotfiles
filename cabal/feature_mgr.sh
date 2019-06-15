#!/bin/bash

_GHC_VERSION=8.0.2

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  _install_fedora_copr
  _install
}

install_redhat() {
  _install_fedora_copr
  _install
}

install_ubuntu() {
  _install
}

install_winbash() {
  _install
}

_install_fedora_copr() {
  repo_family="epel-$OS_MAJOR_RELEASE"
  ghc_pkg="ghc-$_GHC_VERSION"
  set -o pipefail
  curl "https://copr.fedorainfracloud.org/coprs/petersen/$ghc_pkg/repo/$repo_family/petersen-$ghc_pkg-$repo_family.repo" | \
    sudo tee /etc/yum.repos.d/petersen-ghc-epel.repo > /dev/null
}

_install() {
  install_packages cabal-install
  sudo cabal update
}

main "$@"

