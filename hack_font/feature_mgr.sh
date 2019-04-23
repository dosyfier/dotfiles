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

install_winbash() {
  install_ubuntu
}

_install() {
  sudo curl -k -L $HACK_DOWNLOAD_URL -o /var/cache/$HACK_ARCHIVE_NAME
  sudo mkdir -p /usr/local/share/fonts/Hack/
  sudo unzip /var/cache/$HACK_ARCHIVE_NAME -d /usr/local/share/fonts/Hack/
}

main "$@"

