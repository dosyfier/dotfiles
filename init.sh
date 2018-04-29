#!/bin/bash

# -- Functions -- #

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
  [ $return_code -ne 0 ] && exit $return_code
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

  # Create a .dotbashcfg file holding defined DOTBASH_* variables
  cat > ~/.dotbashcfg <<-EOC
#!/bin/bash
DOTBASHCFG_USER="$DOTBASHCFG_USER"
DOTBASHCFG_DATA_DIR="$DOTBASHCFG_DATA_DIR"
EOC

  # Source the bashrc script
  source ~/.bashrc
}


# -- Main program -- #

DOTBASHCFG_USER=$USER
DOTBASHCFG_DATA_DIR=~

while [ $# -ne 0 ]; do
  case "$1" in
    "-l"|"--login")
      shift; DOTBASHCFG_USER=${1:-DOTBASHCFG_USER}
      ;;
    "-d"|"--data")
      shift; DOTBASHCFG_DATA_DIR="${1:-DOTBASHCFG_DATA_DIR}"
      ;;
    "-h"|"-?"|"--help")
      usage; exit 0
      ;;
    *)
      usage; exit 1
      ;;
  esac
  shift
done

run_in_project init
run_in_project packages/install.sh

