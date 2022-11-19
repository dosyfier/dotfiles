#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

HACK_LATEST_VERSION=v2.1.0
HACK_ARCHIVE_NAME=Hack.zip
HACK_DOWNLOAD_URL=https://github.com/ryanoasis/nerd-fonts/releases/download/$HACK_LATEST_VERSION/$HACK_ARCHIVE_NAME

install_centos() {
  _install
}

install_ubuntu() {
  _install
}

install_wsl() {
  _install
  _sync_onto_windows
}

_install() {
  install_packages unzip
  curl -k -L $HACK_DOWNLOAD_URL -o /tmp/$HACK_ARCHIVE_NAME
  trap "rm /tmp/$HACK_ARCHIVE_NAME" EXIT
  rm -rf "$HOME"/.local/share/fonts/Hack/
  mkdir -p "$HOME"/.local/share/fonts/Hack/
  unzip /tmp/$HACK_ARCHIVE_NAME -d "$HOME"/.local/share/fonts/Hack/
}

_sync_onto_windows() {
  sudo rm -f /c/Windows/Fonts/Hack*
  sudo find "$HOME"/.local/share/fonts/Hack/ -type f -name '*.ttf' \
    -exec sudo cp {} /c/Windows/Fonts/ +
}

main "$@"

