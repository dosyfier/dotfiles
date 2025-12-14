#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

HACK_LATEST_VERSION=v3.2.1
HACK_ARCHIVE_NAME=Hack.tar.xz
HACK_DOWNLOAD_URL=https://github.com/ryanoasis/nerd-fonts/releases/download/$HACK_LATEST_VERSION/$HACK_ARCHIVE_NAME

HACK_INSTALL_DIR="$DOTFILES_LOCAL_DIR/share/fonts/Hack"

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
  reset_dir_with_parent "$HACK_INSTALL_DIR"
  run_lenient_sudo bash -c "curl -sSfL '$HACK_DOWNLOAD_URL' | tar -xJ -C '$HACK_INSTALL_DIR'"
}

_sync_onto_windows() {
  run_lenient_sudo rm -f /c/Windows/Fonts/Hack*
  while read -r hack_ttf_file; do
    run_lenient_sudo cp "$hack_ttf_file" /c/Windows/Fonts/
  done < <(find "$HACK_INSTALL_DIR" -type f -name '*.ttf')
}

get_resources() {
  _get_installed_resource "$HACK_INSTALL_DIR"
}

main "$@"

