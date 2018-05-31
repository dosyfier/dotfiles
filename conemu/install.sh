#!/bin/bash

usage() {
  cat <<EOF

  Usage: install.sh (no arguments, no options)
  
  Warning! It is assumed that this script is launched
  from dotbashconfig project root directory !

EOF
}

install() {
  conemu_exe="$(find $DOTBASHCFG_DATA_DIR/{tools,utils} -name 'ConEmu.exe' | head -1)"
  if [ -f "$conemu_exe" ]; then
    conemu_config_file="`dirname $conemu_exe`/ConEmu.xml"
    echo "Setting ConEmu configuration into $conemu_config_file file..."
    cp conemu/ConEmu.xml $conemu_config_file
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

