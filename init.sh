#!/bin/bash

usage() {
  cat <<EOF

  Usage: init.sh (no arguments, no options)

EOF
}

# Run the provided command & arguments into do.bashconfig project's directory
run_in_project() {
  pushd "$(dirname $0)" > /dev/null
  $@
  return_code=$?
  popd > /dev/null
  return $?
}

# Initializes.bash configuration
init() {
  # Build this script's effective parent directory
  # by resolving links and/or trailing ~
  real_dirname="`readlink -f $(dirname $0)`"
  real_dirname="${real_dirname/#\~/$HOME}"

  # If this script isn't launched from ~/.bash dir, then force rebuilding 
  # ~/.bash from the actual dotbashconfig project directory
  if ! [ "$real_dirname" = "$HOME/.bash" ] ; then
    rm -rf "$HOME/.bash"
    rm -f ~/.bashrc
    ln -s "$real_dirname" "$HOME/.bash"
    ln -s ~/.bash/bashrc ~/.bashrc
  fi
 
  git submodule init
  git submodule update
}

# Update all registered.bash plugins at once
update() {
  git submodule foreach git pull origin master
}


# -- Main program -- #

if [[ $1 =~ (-h|--help) ]]; then
  usage; exit 0
elif [ -n "$1" ]; then
  usage; exit 1
else
  run_in_project init
fi

