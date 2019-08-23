#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

HACK_LATEST_VERSION=v3.003
HACK_ARCHIVE_NAME=Hack-$HACK_LATEST_VERSION-ttf.zip
HACK_DOWNLOAD_URL=https://github.com/source-foundry/Hack/releases/download/$HACK_LATEST_VERSION/$HACK_ARCHIVE_NAME

install_centos() {
  _install
}

install_ubuntu() {
  _install
}

install_wsl() {
  _install
  _copy_on_windows
}

_install() {
  install_packages unzip
  sudo curl -k -L $HACK_DOWNLOAD_URL -o /var/cache/$HACK_ARCHIVE_NAME
  sudo mkdir -p /usr/local/share/fonts/Hack/
  sudo unzip /var/cache/$HACK_ARCHIVE_NAME -d /usr/local/share/fonts/Hack/
}

_copy_on_windows() {
  sudo cp /usr/local/share/fonts/Hack/ttf/* /c/Windows/Fonts/
}

main "$@"

