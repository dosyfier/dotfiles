#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

find_as_windows_path() {
  find "$1" -iname "$2" | head -1 | sed 's#^/\([a-z]\)#\U\1:#'
}

replace() {
  pattern="$1"
  replacement="${2//\//\\\\}"
  config_file="$3"

  sed -i "s/$pattern/$replacement/g" "$config_file"
}

abort() {
  (>&2 echo "$1")
  (>&2 echo "Aborting ConEmu feature configuration.")
  exit 1
}

install() {
  if ! [ -d "$DOTBASHCFG_TOOLS_DIR" ]; then
    abort "Tools directory does not exist ($DOTBASHCFG_TOOLS_DIR)."

  else
    conemu_exe="$(find "$DOTBASHCFG_TOOLS_DIR" -name 'ConEmu.exe' | head -1)"

    if [ -f "$conemu_exe" ]; then
      conemu_config_file="$(dirname "$conemu_exe")/ConEmu.xml"

      echo "Setting ConEmu configuration into $conemu_config_file file..."
      cp conemu/ConEmu.xml "$conemu_config_file"

      echo "Configuring $conemu_config_file file..."
      replace "%CygwinHome%" "$(find_as_windows_path "$DOTBASHCFG_TOOLS_DIR" Cygwin64)" "$conemu_config_file"

    else
      abort "No ConEmu installation directory found."
    fi
  fi
}

main "$@"
