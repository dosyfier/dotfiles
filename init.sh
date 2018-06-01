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

  --no-<feature-name>-feature
  --skip-features=<feature-1>,<feature-2>,...,<feature-n>
	  Skip the installation of some given dotbashconfig features (identified by 
	  their "feature-name"). Here is the list of those features:
	      `find . -maxdepth 2 -name install.sh -printf "%h, " | sed -e 's#./##g' -e 's#, $##g'`

  --no-feature|--skip-all-features
	  Skip the installation of every dotbashconfig features (i.e. only bashrc
	  environment will be configured).

  -h|--help
	  Displays this message.

EOU
}

# Run the provided command & arguments into do.bashconfig project's directory
run_in_project() {
  set -e
  pushd "$(dirname $0)" > /dev/null
  trap "popd > /dev/null" EXIT
  $@
}

# Ask the user for the deletion of the file or directory provided as argument:
# - If accepted, remove it and go on,
# - Otherwise, exit in error.
remove_or_abort() {
  if [ -e "$1" ]; then
    echo "Existing $1 detected..."
    while ! [[ $REPLY =~ ^[yn]$ ]]; do
      read -p "Override? [y/n] " -r
    done
    if [ $REPLY = y ]; then
      rm -rf "$1"
    else
      return 2
    fi
  fi
}

# Initializes.bash configuration
init() {
  # Build this script's effective parent directory
  # by resolving links and/or trailing ~
  # (using pwd since we are necessarily in dotbashconfig dir,
  # and because, due to run_in_project, '$(dirname $0)' would be wrong)
  real_dirname="`readlink -f $(pwd)`"
  real_dirname="${real_dirname/#\~/$HOME}"

  # If this script isn't launched from ~/.bash dir, then force rebuilding 
  # ~/.bash from the actual dotbashconfig project directory
  echo "Init $HOME/.bash..."
  if ! [ "$real_dirname" = "$(readlink -f $HOME/.bash)" ] ; then
    remove_or_abort "$HOME/.bash"
    ln -s "$real_dirname" "$HOME/.bash"
  fi

  # Erase existing .bashrc, and warn the user about it first
  echo "Init $HOME/.bashrc..."
  if ! [ -e "$HOME/.bashrc" ] || ! [ -L "$HOME/.bashrc" ] || \
	! [ "$real_dirname/bashrc" = "$(readlink -f $HOME/.bashrc)" ]; then
    remove_or_abort "$HOME/.bashrc"
    ln -s $HOME/.bash/bashrc $HOME/.bashrc
  fi

  # Create a .dotbashcfg file holding defined DOTBASH_* variables
  cat > $HOME/.dotbashcfg <<-EOC
#!/bin/bash
DOTBASHCFG_WIN_USER="$DOTBASHCFG_WIN_USER"
DOTBASHCFG_DATA_DIR="$DOTBASHCFG_DATA_DIR"
EOC

  # Source the bashrc script
  source $HOME/.bashrc
}

# Locate and execute every dotbashconfig feature installation script, with
# skipping of the features that are deactivated based on this script's options.
install_features() {
  for install_script in */install.sh; do
    feature=$(basename $(dirname $install_script))
    skip_feature_var_name=SKIP_${feature^^}_FEATURE
    if ! [ "${!skip_feature_var_name}" = true ]; then
      echo "Install / Configure $feature feature..."
      run_in_project $install_script
    fi
  done
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
    --no-*-feature)
      feature=`expr $1 : '--no-\(.*\)-feature'`
      declare "SKIP_${feature^^}_FEATURE=true"
      ;;
    --skip-features=*)
      for feature in `echo ${1// /} | cut -d= -f2 | sed 's/,/ /g'`; do
	declare "SKIP_${feature^^}_FEATURE=true"
      done
      ;;
    "--no-feature"|"--skip-all-features")
      SKIP_ALL_FEATURES=true
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

# Install each dotbashconfig feature (unless deactivated)
if ! [ "${SKIP_ALL_FEATURES}" = true ]; then
  run_in_project install_features
fi

# Done!
echo "Done! Enjoy bashing ;-)"

