#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

GO_VERSION=1.25.3
GO_ARCHIVE_NAME=go${GO_VERSION}.linux-amd64.tar.gz
GO_DOWNLOAD_URL=https://go.dev/dl/$GO_ARCHIVE_NAME

# shellcheck source=aliases/go.sh
source "$(dirname "$0")/aliases/go.sh"

install_common() {
  reset_dir_with_parent "$GO_HOME"
  run_lenient_sudo bash -c "curl -sSfL '$GO_DOWNLOAD_URL' | \
tar --strip-components=1 -C '$(dirname "$GO_HOME")' -xz"
}

main "$@"
