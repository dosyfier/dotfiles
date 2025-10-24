#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

GO_VERSION=1.25.3
GO_ARCHIVE_NAME=go${GO_VERSION}.linux-amd64.tar.gz
GO_DOWNLOAD_URL=https://go.dev/dl/$GO_ARCHIVE_NAME

install_common() {
  remove_or_abort "$DOTFILES_TOOLS_DIR/go" sudo
  sudo bash -c "curl -sSfL '$GO_DOWNLOAD_URL' | tar -C '$DOTFILES_TOOLS_DIR' -xz"
}

main "$@"
