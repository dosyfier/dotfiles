#!/bin/bash

# -- Constants -- #

DOTBASH_CFG_FILE=$HOME/.dotbashcfg

# Build this script's effective parent directory
# by resolving links and/or trailing ~
DOTBASH_CFG_DIR="$(readlink -f "$(dirname "$0")")"
DOTBASH_CFG_DIR="${DOTBASH_CFG_DIR/#\~/$HOME}"


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

  --with-<feature-name>-feature
  --with-features=<feature-1>,<feature-2>,...,<feature-n>
	  Skip the installation of some given dotbashconfig features (identified by 
	  their "feature-name"). Here is the list of those features:
	      $(find . -maxdepth 2 -name install.sh -printf "%h, " | sed -e 's#./##g' -e 's#, $##g')

  -y|--all-features
	  Skip the installation of every dotbashconfig features (i.e. only bashrc
	  environment will be configured).

  -h|--help
	  Displays this message.

EOU
}

# Run the provided command & arguments into do.bashconfig project's directory
run_in_project() {
  set -e
  pushd "$DOTBASH_CFG_DIR" > /dev/null
  trap "popd > /dev/null" EXIT
  # shellcheck disable=SC2068
  # Array expansion is intended this way
  $@
}

# Ask the user for the deletion of the file or directory provided as argument:
# - If accepted, remove it and go on,
# - Otherwise, exit in error.
remove_or_abort() {
  if [ -e "$1" ]; then
    if ok_to "Existing $1 detected..." "Override?"; then
      rm -rf "$1"
    else
      return 2
    fi
  fi
}

# Ask the user a yes/no question and pick up his/her answer.
# $1 - Preamble message (optional)
# $2 - Main prompt message
ok_to() {
  [ $# -eq 2 ] && ( echo "$1"; shift )
  REPLY=""
  while ! [[ $REPLY =~ ^[yn]$ ]]; do
    read -p "$1 [y/n] " -r
  done
  [ "$REPLY" = y ]
  return $?
}

# Initializes.bash configuration
init() {
  # If this script isn't launched from ~/.bash dir, then force rebuilding 
  # ~/.bash from the actual dotbashconfig project directory
  echo "Init $HOME/.bash..."
  if ! [ "$DOTBASH_CFG_DIR" = "$(readlink -f "$HOME/.bash")" ] ; then
    remove_or_abort "$HOME/.bash"
    ln -s "$DOTBASH_CFG_DIR" "$HOME/.bash"
  fi

  # Erase existing .bashrc, and warn the user about it first
  echo "Init $HOME/.bashrc..."
  if ! [ -e "$HOME/.bashrc" ] || ! [ -L "$HOME/.bashrc" ] || \
	! [ "$DOTBASH_CFG_DIR/bashrc" = "$(readlink -f "$HOME/.bashrc")" ]; then
    remove_or_abort "$HOME/.bashrc"
    ln -s "$HOME/.bash/bashrc" "$HOME/.bashrc"
  fi

  # Create a .dotbashcfg file holding defined DOTBASH_* variables
  cat > "$DOTBASH_CFG_FILE" <<-EOC
#!/bin/bash
DOTBASHCFG_WIN_USER="$DOTBASHCFG_WIN_USER"
DOTBASHCFG_DATA_DIR="$DOTBASHCFG_DATA_DIR"
EOC

  # Source the bashrc script
  source "$HOME/.bashrc"
}

# Check whether some feature shall be installed or not.
# $1 - The feature to check
check_feature() {
  feature="$1"
  if [ "$RUN_ALL_FEATURES" = true ]; then
    return 0
  elif [ "$AUTO_DOTBASH_CFG" = true ]; then
    run_feature_var_name=RUN_${feature^^}_FEATURE
    [ "${!run_feature_var_name}" = true ]
    return $?
  else
    ok_to "Install $feature feature?"
    return $?
  fi
}

# Locate and execute every dotbashconfig feature installation script that has
# been activated (based on this script's options).
install_features() {
  for install_script in */install.sh; do
    feature=$(basename "$(dirname "$install_script")")
    if check_feature "$feature"; then
      echo "Install / Configure $feature feature..."
      run_in_project "$install_script"
    fi
  done
}


# -- Main program -- #

# Default variables
if [ -f "$DOTBASH_CFG_FILE" ]; then
  source "$DOTBASH_CFG_FILE"
else
  DOTBASHCFG_WIN_USER=$USER
  DOTBASHCFG_DATA_DIR=~
fi

# Parse program options
while [ $# -ne 0 ]; do
  case "$1" in
    "-l"|"--win-login")
      shift; DOTBASHCFG_WIN_USER=${1:-DOTBASHCFG_WIN_USER}
      ;;
    "-d"|"--data")
      shift; DOTBASHCFG_DATA_DIR="${1:-DOTBASHCFG_DATA_DIR}"
      ;;
    --with-*-feature)
      feature=$(expr "$1" : '--with-\(.*\)-feature')
      declare "RUN_${feature^^}_FEATURE=true"
      AUTO_DOTBASH_CFG=true
      ;;
    --with-features=*)
      for feature in $(echo "${1// /}" | cut -d= -f2 | sed 's/,/ /g'); do
	declare "RUN_${feature^^}_FEATURE=true"
      done
      AUTO_DOTBASH_CFG=true
      ;;
    "-y"|"--all-features")
      RUN_ALL_FEATURES=true
      AUTO_DOTBASH_CFG=true
      ;;
    "-h"|"-?"|"--help")
      run_in_project usage; exit 0
      ;;
    *)
      run_in_project usage; exit 1
      ;;
  esac
  shift
done

# Run bash env initialization
echo "Init bash environment..."
run_in_project init

# Install each dotbashconfig feature
run_in_project install_features

# Done!
echo "Done! Enjoy bashing ;-)"

