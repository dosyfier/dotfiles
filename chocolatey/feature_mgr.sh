#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_wsl() {
  if ! command -v choco.exe > /dev/null 2>&1; then
    # Official install command
    powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass \
      -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
  fi

  # Create aliases for each Chocolatey program beginning with a 'c'
  # (choco, cinst, clist, ...)
  # and make them available in PATH and as sudo
  choco_bin_dir=/mnt/c/ProgramData/chocolatey/bin
  for choco_bin in "$choco_bin_dir"/c*; do
    choco_name=$(basename "$choco_bin")
    choco_link="/usr/local/sbin/${choco_name/.exe/}"
    if [ ! -e "$choco_link" ]; then
      sudo ln -vs "$choco_bin" "$choco_link"
    fi
  done

  choco upgrade chocolatey

  # shellcheck source=aliases/chocolatey.sh
  source "$FEATURE_ROOT/aliases/chocolatey.sh"
}

main "$@"

