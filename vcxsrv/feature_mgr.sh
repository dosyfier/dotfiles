#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

install_winbash() {
  vcxsrv_install_dir='/c/Program Files/VcXsrv'

  # Installing VcXsrv Windows application
  if [ -f "$vcxsrv_install_dir/vcxsrv.exe" ]; then
    echo "VcXsrv is already installed. Nothing to do."
  else
    installer_temp_loc="$WIN_HOME/Downloads/vcxsrv-installer.exe"
    curl -L https://sourceforge.net/projects/vcxsrv/files/latest/download -o "$installer_temp_loc"
    trap "rm -f '$installer_temp_loc'" EXIT
    pushd "$(dirname "$installer_temp_loc")" > /dev/null
    trap 'popd > /dev/null' EXIT
    ./$(basename "$installer_temp_loc") /S
  fi

  # Setting configuration and auto launch
  echo "(Re)Installing VcXsrv configuration..."
  cp "$FEATURE_ROOT"/config.xlaunch "$vcxsrv_install_dir/"
  echo "(Re)Configuring VcXsrv auto launch..."
  reg.exe add HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run \
    /v VcXsrv /d "\"C:\\Program Files\\VcXsrv\\config.xlaunch\"" /f
}

main "$@"

