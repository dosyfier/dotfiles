#!/bin/bash

SHELLCHECK_VERSION=0.11.0

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_common() {
  install_packages xz

  shellcheck_download_url="https://github.com/koalaman/shellcheck"
  shellcheck_download_url+="/releases/download/v$SHELLCHECK_VERSION"
  shellcheck_download_url+="/shellcheck-v$SHELLCHECK_VERSION.linux.x86_64.tar.xz"

  ensure_dir_exists "$DOTFILES_LOCAL_DIR/bin"
  run_lenient_sudo bash -c "curl -sSfL '$shellcheck_download_url' | \
tar -xJ -C '$DOTFILES_LOCAL_DIR/bin' --strip-components=1 shellcheck-v$SHELLCHECK_VERSION/shellcheck"
}

main "$@"
