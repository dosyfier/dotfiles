#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
}

install_common() {
  if ! [ -d ~/.jenv ]; then
    git clone https://github.com/jenv/jenv.git ~/.jenv
  fi
}

main "$@"
