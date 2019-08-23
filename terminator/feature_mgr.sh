#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if [ $(get_distro_type) == 'wsl' ]; then
    echo vcxsrv
  fi
}

install_centos() {
  install_packages terminator
  _configure
}

install_wsl() {
  # N.B. Python pip is required by the terminator-themes plugin
  install_packages terminator dbus-x11 python-pip
  sudo systemd-machine-id-setup
  _configure

  # Link to Windows fonts (to make them available to configure terminator)
  if ! [ -e "/usr/local/share/fonts/windows" ]; then
    mkdir -p /usr/local/share/fonts
    sudo ln -s /mnt/c/Windows/Fonts /usr/local/share/fonts/windows
  fi

  # Copying terminator config files (launch script, icon, ...) under $DOTBASHCFG_TOOLS_DIR
  if ! [ -d "$DOTBASHCFG_TOOLS_DIR" ]; then
    (>&2 echo "Directory $DOTBASHCFG_TOOLS_DIR does not exist. Aborting terminator feature installation.")
    return 1
  fi
  terminator_quick_launch_dir="$DOTBASHCFG_TOOLS_DIR"/terminator/quick_launch
  echo "Installing terminator launch configuration under $terminator_quick_launch_dir..."
  mkdir -p "$terminator_quick_launch_dir"
  rm -rf "$terminator_quick_launch_dir"/*
  cp -r "$FEATURE_ROOT"/{icons,vbs} "$terminator_quick_launch_dir"

  # Windows shortcut
  pushd "$terminator_quick_launch_dir/vbs" > /dev/null
  trap "popd > /dev/null" EXIT
  echo "Creating terminator Windows shortcut..."
  cscript.exe "setup_terminator_shortcut.vbs" "$(wslpath -w "$terminator_quick_launch_dir")"

  # Linux icon (displayed through VcXsrv)
  echo "Updating terminator Linux icon..."
  main_icon_dir=/usr/share/icons/hicolor/16x16/apps
  if [ -f "$main_icon_dir"/terminator.png ] && ! [ -f "$main_icon_dir"/terminator-bak.png ]; then
    sudo mv "$main_icon_dir"/terminator{,-bak}.png
  fi
  sudo cp "$FEATURE_ROOT"/icons/terminator.png "$main_icon_dir"/
  sudo chmod 644 "$main_icon_dir"/terminator.png
}

_configure() {
  # Create terminator config directory
  mkdir -p "$HOME/.config/terminator/plugins"
  
  # Install plugins
  echo "Installing terminator 'themes' plugin..."
  sudo pip install requests
  curl -k -L https://git.io/v5Zww -o "$HOME/.config/terminator/plugins/terminator-themes.py"

  # Install configuration file
  terminator_config_file="$HOME/.config/terminator/config"
  if [ -e "$terminator_config_file" ]; then
    (>&2 echo "Terminator config file already exists ($terminator_config_file). Not overriding.")
  else
    echo "Installing terminator config file ($terminator_config_file)..."
    rm -f "$terminator_config_file" # in case the link is broken...
    ln -s "$FEATURE_ROOT"/conf/terminator.config "$terminator_config_file"
  fi
}

main "$@"

