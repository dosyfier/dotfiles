#!/bin/bash

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

shall_be_installed_by_default() {
  # No need to install an additional X-server when WSLg is activated
  [ "$win_os" = true ] && is_wslg_active
}

install_wsl() {
  vcxsrv_install_dir='/c/Program Files/VcXsrv'

  # Installing VcXsrv Windows application
  if [ -f "$vcxsrv_install_dir/vcxsrv.exe" ]; then
    echo "VcXsrv is already installed. Nothing to do."
  else
    installer_temp_loc="$WIN_HOME/Downloads/vcxsrv-installer.exe"
    if ! [ -f "$installer_temp_loc" ]; then
      curl -L https://sourceforge.net/projects/vcxsrv/files/latest/download -o "$installer_temp_loc"
    fi
    # shellcheck disable=2064
    #   Expanding now rather than when signalled is intended
    trap "rm -f $installer_temp_loc" EXIT
    pushd "$(dirname "$installer_temp_loc")" > /dev/null
    trap 'popd > /dev/null' EXIT
    echo "Running VcXsrv installer ($installer_temp_loc)..."
    ./"$(basename "$installer_temp_loc")" /S
  fi

  # Setting configuration and auto launch
  echo "(Re)Installing VcXsrv configuration..."
  cp "$FEATURE_ROOT"/config.xlaunch "$vcxsrv_install_dir/"
  echo "(Re)Configuring VcXsrv auto launch..."
  reg.exe add HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run \
    /v VcXsrv /d "C:\\Program Files\\VcXsrv\\config.xlaunch" /f
}

main "$@"

