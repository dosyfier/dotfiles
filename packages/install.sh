#!/bin/bash

usage() {
  cat <<EOF

  Usage: install.sh (no arguments, no options)

EOF
}

install() {
  distro=`get_distro`
  if [ -f "`dirname $0`/${distro}.sh" ]; then
    `dirname $0`/${distro}.sh
  elif [ -n "$distro" ]; then
    echo "Nothing to install for this distro."
  else
    echo "Unknown distro, cannot install packages..." >&2
  fi
}


# -- Main program -- #

if [[ $1 =~ (-h|--help) ]]; then
  usage; exit 0
elif [ -n "$1" ]; then
  usage; exit 1
else
  source ~/.bash/bash.d/distro.sh
  install
fi

