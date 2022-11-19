#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

install_common() {
  echo "Note: This feature doesn't install Eclipse."
  echo "It is only about setting up a custom Vrapper plugin config file."
  _configure
}

_configure() {
  # Link $HOME/.vrapperrc file
  for v in HOME WIN_HOME; do
    if [ -v "$v" ]; then
      if ! [ -e "$v/.vrapperrc" ]; then
        ln -s "$FEATURE_ROOT/vrapperrc" "$v/.vrapperrc"
      fi
    fi
  done
}

main "$@"

