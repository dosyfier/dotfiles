#!/bin/bash -e

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_wsl() {
  if ! command -v choco.exe > /dev/null 2>&1; then
    # Official install command
    powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass \
      -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    PATH="$PATH;/mnt/c/ProgramData/chocolatey/bin"

    # shellcheck source=aliases/chocolatey.sh
    source "$FEATURE_ROOT/aliases/chocolatey.sh"

  else
    choco upgrade chocolatey
  fi
}

main "$@"

