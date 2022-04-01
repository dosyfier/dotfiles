#!/bin/bash -e

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_wsl() {
  # The whole purpose of this install function is to register Windows tasks that
  # will automatically update WSL networking settings when the workstation connects
  # to a VPN. This aims at being able to access the Internet & public DNS even while
  # being connected to a VPN.

  # Configure WSL so that it doesn't edit resolv.conf file
  if ! [ -f /etc/wsl.conf ] || ! grep -q '^\[network\]' /etc/wsl.conf; then
    sudo bash -c 'printf "[network]\ngenerateResolvConf = false\n" >> /etc/wsl.conf'
  elif grep -q generateResolvConf /etc/wsl.conf; then
    sudo sed -i '/^\[network\]/,/^\[/ s/^\(generateResolvConf\s*=\s*\).*$/\1false/' /etc/wsl.conf
  else
    sudo sed -i '/^\[network\]/a generateResolvConf = false' /etc/wsl.conf
  fi

  # Make sure that, technically speaking, the resolv.conf file cannot be edited
  if [ -L /etc/resolv.conf ]; then
    sudo rm -f /etc/resolv.conf
    sudo touch /etc/resolv.conf

    # Cf. https://github.com/microsoft/WSL/issues/1908#issuecomment-641396913
    # This will make the file immutable and not overwritten next time WSL starts.
    sudo chattr +i /etc/resolv.conf
  fi
  
  # Copy Powershell scripts into a Windows-located directory
  wsl_scripts_dir="$DOTBASHCFG_TOOLS_DIR/wsl/scripts"
  mkdir -p "$wsl_scripts_dir"
  cp -v "$FEATURE_ROOT"/tasks/*.ps1 "$wsl_scripts_dir"/

  # Register them as scheduled tasks to be trigger when connecting / disconnecting a VPN
  powershell.exe "$(wslpath -m "$FEATURE_ROOT")\\install_win_tasks.ps1"
}

set -euo pipefail

main "$@"

