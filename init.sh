#!/bin/bash

# -- Functions -- #

usage() {
  cat <<EOU

  Usage: init.sh [options] 
  where available options are:

  -l|--win-login <login>
	  Login of the actual Windows account, to be used when installing 
	  dotbashconfig from some Shell environment run from Windows (e.g. Cygwin,
	  Git Bash, WSL).

  -d|--data <data-dir>
	  Optional path indicating the root of a directory holding any development
	  project, 3rd party tool installation, IDE installation, etc. (used e.g. 
	  on Windows to find Cygwin installation path).

  --no-pkg-install
	  Skip base development packages installation (i.e. when you don't want
	  any supplementary package being installed onto your system when running
	  .bash/init.sh script.

  -h|--help
	  Displays this message.

EOU
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
    ln -s "$real_dirname" "$HOME/.bash"
  fi

  # Erase existing, and (TODO) warn the user about it
  rm -f ~/.bashrc
  ln -s ~/.bash/bashrc ~/.bashrc

  # Create a .dotbashcfg file holding defined DOTBASH_* variables
  cat > ~/.dotbashcfg <<-EOC
#!/bin/bash
DOTBASHCFG_WIN_USER="$DOTBASHCFG_WIN_USER"
DOTBASHCFG_DATA_DIR="$DOTBASHCFG_DATA_DIR"
EOC

  # Source the bashrc script
  source ~/.bashrc
}


# -- Main program -- #

# Default variables
DOTBASHCFG_WIN_USER=$USER
DOTBASHCFG_DATA_DIR=~

# Parse program options
while [ $# -ne 0 ]; do
  case "$1" in
    "-l"|"--win-login")
      shift; DOTBASHCFG_WIN_USER=${1:-DOTBASHCFG_WIN_USER}
      ;;
    "-d"|"--data")
      shift; DOTBASHCFG_DATA_DIR="${1:-DOTBASHCFG_DATA_DIR}"
      ;;
    "--no-pkg-install")
      SKIP_PKG_INSTALL=true
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

# Run bash env initialization
echo "Init bash environment..."
run_in_project init

# Unless deactivated, install base dev packages
if ! [ "$SKIP_PKG_INSTALL" = true ]; then
  echo "Install base dev packages..."
  run_in_project packages/install.sh
fi

# Done!
echo "Done! Enjoy bashing ;-)"

