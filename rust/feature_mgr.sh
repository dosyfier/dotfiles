#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_common() {
  curl https://sh.rustup.rs -sSf | sh -s - -y --no-modify-path
}

main "$@"
