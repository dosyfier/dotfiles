#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  _configure_gnome
}

_configure_gnome() {
  # Font size
  echo "Configuring font size..."
  dconf write /org/gnome/desktop/interface/font-name "'Cantarell 10'"
  dconf write /org/gnome/desktop/interface/monospace-font-name "'Monospace 9'"
  dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Cantarell Bold 10'"

  # Necessary for BN1 Eclipse desktop shortcut to work
  echo "Configuring desktop settings..."
  dconf write /org/gnome/nautilus/preferences/executable-text-activation "'launch'"

  # Done!
  echo "GNOME configured!"
}

main "$@"

