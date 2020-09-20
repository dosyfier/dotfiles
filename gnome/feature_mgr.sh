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

  # GNOME Terminal settings
  echo "Configuring terminal background..."
  profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
  profile=${profile:1:-1} # remove leading and trailing single quotes
  gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" use-theme-colors false

  # Prevent screen locking (useful for vagrant)
  if id vagrant &>/dev/null; then
    gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
  fi

  # Necessary for desktop shortcuts to work
  echo "Configuring desktop settings..."
  dconf write /org/gnome/nautilus/preferences/executable-text-activation "'launch'"

  # Done!
  echo "GNOME configured!"
}

main "$@"

