#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

HACK_LATEST_VERSION=v3.2.1
HACK_ARCHIVE_NAME=Hack.tar.xz
HACK_DOWNLOAD_URL=https://github.com/ryanoasis/nerd-fonts/releases/download/$HACK_LATEST_VERSION/$HACK_ARCHIVE_NAME

install_common() {
  _install
}

install_rhel() {
  _install xz
}

install_wsl() {
  _install
  _sync_onto_windows
}

_install() {
  install_packages "${1:-xz-utils}"
  rm -rf "$HOME"/.local/share/fonts/Hack/
  mkdir -p "$HOME"/.local/share/fonts/Hack/
  curl -sSfL "$HACK_DOWNLOAD_URL" | tar -xJ -C "$HOME"/.local/share/fonts/Hack/
}

_sync_onto_windows() {
  sudo rm -f /c/Windows/Fonts/Hack*
  sudo find "$HOME"/.local/share/fonts/Hack/ -type f -name '*.ttf' \
    -exec sudo cp {} /c/Windows/Fonts/ \;
}

get_resources() {
  _get_installed_resource "$HOME/".local/share/fonts/Hack
}

main "$@"

