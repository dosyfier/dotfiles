#!/bin/bash -e

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_ubuntu() {
  _install
}

install_wsl() {
  _install
}

_install() {
  # Install tmux itself
  install_packages tmux

  # Install its configuration file
  tmux_config_file="$HOME/.tmux.conf"
  if [ -e "$tmux_config_file" ]; then
    (>&2 echo "Tmux config file already exists ($tmux_config_file). Not overriding.")
  else
    echo "Installing tmux config file ($tmux_config_file)..."
    rm -f "$tmux_config_file" # in case the link is broken...
    ln -s "$FEATURE_ROOT"/conf/tmux.conf "$tmux_config_file"
  fi
}

get_resources() {
  _get_installed_resource "$HOME/.tmux.conf" "$HOME/.tmux-sessions.properties"
}

main "$@"
