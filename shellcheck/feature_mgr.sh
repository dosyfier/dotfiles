#!/bin/bash

_SHELLCHECK_VERSION=0.8.0
_SHELLCHECK_SRC_DIR=/usr/local/src/shellcheck

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  echo cabal
  if ! command -v git > /dev/null 2>&1; then
    echo git
  fi
}

install_centos() {
  _install
}

install_redhat() {
  _install
}

install_ubuntu() {
  _install
}

install_wsl() {
  _install
}

_install() {
  if command -v shellcheck > /dev/null 2>&1 && \
    [ "$(shellcheck --version | awk '/version:/ { print $NF; quit }')" = "$_SHELLCHECK_VERSION" ]; then
    echo "ShellCheck is already installed in version $_SHELLCHECK_VERSION. Skipping."

  else
    # Re-update cabal (when the feature is played indepently, without the "cabal" feature)
    sudo cabal update

    # Clone ShellCheck official git repository and switch to the desired branch / tag
    if ! [ -d "$_SHELLCHECK_SRC_DIR" ]; then
      sudo git clone https://github.com/koalaman/shellcheck "$_SHELLCHECK_SRC_DIR"
      sudo git -C "$_SHELLCHECK_SRC_DIR" checkout "v${_SHELLCHECK_VERSION}"
    fi

    # Install ShellCheck globally
    sudo bash -c "cd $_SHELLCHECK_SRC_DIR; cabal install --global"
  fi
}

main "$@"

