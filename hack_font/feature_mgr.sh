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
  sudo curl -k -L $HACK_DOWNLOAD_URL -o /var/cache/$HACK_ARCHIVE_NAME
  sudo rm -rf /usr/local/share/fonts/Hack/
  sudo mkdir -p /usr/local/share/fonts/Hack/
  sudo unzip /var/cache/$HACK_ARCHIVE_NAME -d /usr/local/share/fonts/Hack/
}

_sync_onto_windows() {
  sudo rm -f /c/Windows/Fonts/Hack*
  sudo find /usr/local/share/fonts/Hack/ -type f -name '*.ttf' -exec cp {} /c/Windows/Fonts/ +
}

main "$@"

