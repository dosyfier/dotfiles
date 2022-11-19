#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

install_ubuntu() {
  install_packages subversion
  _configure
}

install_wsl() {
  install_ubuntu
}

_configure() {
  # Create $HOME/.subversion dir
  mkdir -p "$HOME/.subversion"

  # Link $HOME/.subversion/vimdiff-wrapper.sh script
  if ! [ -e "$HOME/.subversion/vimdiff-wrapper.sh" ]; then
    ln -s "$FEATURE_ROOT/vimdiff-wrapper.sh" "$HOME/.subversion/vimdiff-wrapper.sh"
  fi

  # Create SVN config file
  if [ -e "$HOME/.subversion/config" ]; then
    (>&2 echo "Subversion config file already exists ($HOME/.subversion/config). Not overriding.")
  else
    cp -v "$FEATURE_ROOT"/config "$HOME/.subversion/config"
    sed -i "s#\$HOME#$HOME#g" "$HOME/.subversion/config"
  fi
}

get_resources() {
  _get_installed_resource "$HOME/.subversion"
}

main "$@"
