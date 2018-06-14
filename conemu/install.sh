#!/bin/bash

usage() {
  cat <<EOF

  Usage: install.sh (no arguments, no options)
  
  Warning! It is assumed that this script is launched
  from dotbashconfig project root directory !

EOF
}

find_tools_dir() {
  if [ -d $DOTBASHCFG_DATA_DIR/tools ]; then
    echo "$DOTBASHCFG_DATA_DIR/tools"
  elif [ -d $DOTBASHCFG_DATA_DIR/utils ]; then
    echo "$DOTBASHCFG_DATA_DIR/utils"
  else
    (>&2 echo "Unable to find path for $1.")
    (>&2 echo "None of the following directories exist:")
    (>&2 echo "- $DOTBASHCFG_DATA_DIR/tools")
    (>&2 echo "- $DOTBASHCFG_DATA_DIR/utils")
    return 1;
  fi
}

find_as_windows_path() {
  find $1 -iname "$2" | head -1 | sed 's#^/\([a-z]\)#\U\1:#'
}

replace() {
  pattern="$1"
  replacement="${2//\//\\\\}"
  config_file="$3"

  sed -i "s/$pattern/$replacement/g" "$config_file"
}

install() {
  tools_dir="$(find_tools_dir)"
  conemu_exe="$(find "$tools_dir" -name 'ConEmu.exe' | head -1)"
  if [ -f "$conemu_exe" ]; then
    conemu_config_file="`dirname $conemu_exe`/ConEmu.xml"

    echo "Setting ConEmu configuration into $conemu_config_file file..."
    cp conemu/ConEmu.xml $conemu_config_file

    echo "Configuring $conemu_config_file file..."
    replace "%CygwinHome%" "$(find_as_windows_path "$tools_dir" Cygwin64)" $conemu_config_file

  else
    echo "No ConEmu installation directory found. Aborting ConEmu feature configuration."
  fi
}


# -- Main program -- #

if [[ $1 =~ (-h|--help) ]]; then
  usage; exit 0
elif [ -n "$1" ]; then
  usage; exit 1
else
  source ~/.dotbashcfg
  install
fi

