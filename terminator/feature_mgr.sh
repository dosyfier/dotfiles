#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(realpath "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

install_winbash() {
  if ! [ -e "/usr/share/fonts/windows" ]; then
    sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/windows
  fi

  install_packages terminator

  if ! [ -d "$DOTBASHCFG_TOOLS_DIR" ]; then
    (>&2 echo "Directory $DOTBASHCFG_TOOLS_DIR does not exist. Aborting terminator feature installation.")
    return 1
  fi

  terminator_quick_launch_dir="$DOTBASHCFG_TOOLS_DIR"/terminator/quick_launch
  mkdir -p "$terminator_quick_launch_dir"
  cp "$FEATURE_ROOT"/*.{ico,vbs} "$terminator_quick_launch_dir"

  pushd "$terminator_quick_launch_dir" > /dev/null
  trap "popd > /dev/null" EXIT
  cscript.exe "setup_terminator_shortcut.vbs" "$(_to_windows_path "$terminator_quick_launch_dir")"

  mkdir -p "$HOME/.config/terminator"
  terminator_config_file="$HOME/.config/terminator/config"
  if [ -e "$terminator_config_file" ]; then
    (>&2 echo "Terminator config file already exists ($terminator_config_file). Not overriding.")
  else
    ln -s "$FEATURE_ROOT"/terminator.config "$terminator_config_file"
  fi
}

_to_windows_path() {
  echo "$1" | sed -e 's|^\(/mnt/\)|/|' -e 's|^/\([a-z]\)|\U\1:|' -e 's|/|\\|g'
}

main "$@"

