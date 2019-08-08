#!/bin/bash

# -- Constants -- #

DOTBASH_CFG_FILE=$HOME/.dotbashcfg

# Build this script's effective parent directory
# by resolving links and/or trailing ~
DOTBASH_CFG_DIR="$(readlink -f "$(dirname "$0")")"
DOTBASH_CFG_DIR="${DOTBASH_CFG_DIR/#\~/$HOME}"


# -- Utility functions -- #

source "$DOTBASH_CFG_DIR/internal/init-utils.sh"

# Run the provided command & arguments into do.bashconfig project's directory
run_in_project() {
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
  [ $# -eq 2 ] && echo "$1" && shift 
  REPLY=""
  while ! [[ $REPLY =~ ^[yn]$ ]]; do
    read -p "$1 [y/n] " -r
  done
  [ "$REPLY" = y ]
  return $?
}

# Process the standard input by keeping only one occurrence for every line.
uniq_occurrences() {
  # This command is telling awk which lines to print. The variable $0 holds 
  # the entire contents of a line and square brackets are array access. So,
  # for each line of the file, the node of the array x is incremented and the
  # line printed if the content of that node was not (!) previously set.
  tr ' ' '\n' | awk '!x[$0]++'
}

# Process the standard input by excluding the lines matching elements of some
# provided array.
# $1 - The array containing elements to exclude from the stream.
without_excluded() {
  exclude_array_name="$1[*]"
  tr ' ' '\n' | while read -r element; do
    if ! [[ " ${!exclude_array_name} " =~ " $element " ]]; then
      echo "$element"
    fi
  done
}


# --- Installation algorithm -- #

# Take into account the values of options passed to this init script.
# N.B. As a prerequisite, those values have been pre-parsed by the "parse_args"
# function from the init-utils.sh script.
acknowledge_opts() {
  # If 'help' option was set, don't do anything more
  if [ -n "${DOTBASHCFG_VALUES[help]}" ]; then
    run_in_project usage; exit 0
  fi

  DOTBASHCFG_WIN_USER=${DOTBASHCFG_VALUES[win_login]:-$DOTBASHCFG_WIN_USER}
  DOTBASHCFG_MAIL=${DOTBASHCFG_VALUES[email]:-$DOTBASHCFG_MAIL}
  DOTBASHCFG_DATA_DIR=${DOTBASHCFG_VALUES[data_dir]:-$DOTBASHCFG_DATA_DIR}

  # Check exclusive options: with_features, all_features and skip_install
  nb_exclusive_opts="$(echo "${DOTBASHCFG_VALUES[with_features]}" \
    "${DOTBASHCFG_VALUES[all_features]}" \
    "${DOTBASHCFG_VALUES[skip_install]}" | wc -w)"
  if [ $nb_exclusive_opts -gt 1 ]; then
    usage_error "Only one of the following options can be specified at once:" \
      "¤ ${DOTBASHCFG_SHORT_OPTS[all_features]}|${DOTBASHCFG_LONG_OPTS[all_features]}" \
      "¤ ${DOTBASHCFG_SHORT_OPTS[skip_install]}|${DOTBASHCFG_LONG_OPTS[skip_install]}" \
      "¤ ${DOTBASHCFG_SHORT_OPTS[with_features]}|${DOTBASHCFG_LONG_OPTS[with_features]}|${DOTBASHCFG_EXTRA_OPTS[with_features]}"
  fi

  if [ -n "${DOTBASHCFG_VALUES[with_features]}" ]; then
    for feature in $(echo "${DOTBASHCFG_VALUES[with_features]}" | sed 's/,/ /g'); do
      if [ -f $feature/feature_mgr.sh ]; then
	declare -g "RUN_${feature^^}_FEATURE=true"
      else
	usage_error "Requested feature $feature does not exist" \
	  "Available features are:" \
	  "$(available_features | fold -w 80 -s)"
      fi
    done
    AUTO_DOTBASH_CFG=true

  elif [ -n "${DOTBASHCFG_VALUES[all_features]}" ]; then
    RUN_ALL_FEATURES=true
    AUTO_DOTBASH_CFG=true

  elif [ -n "${DOTBASHCFG_VALUES[skip_install]}" ]; then
    SKIP_FEATURES_INSTALLATION=true
  fi
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

  # Create the data and tools directories if they don't exist
  if ! [ -d "$DOTBASHCFG_DATA_DIR" ] || ! [ -d "$DOTBASHCFG_DATA_DIR/tools" ]; then
    mkdir -p "$DOTBASHCFG_DATA_DIR/tools"
  fi

  # Create a .dotbashcfg file holding defined DOTBASH_* variables
  echo "Backup dotbashconfig configuration into $DOTBASH_CFG_FILE..."
  cat > "$DOTBASH_CFG_FILE" <<-EOC
#!/bin/bash
export DOTBASHCFG_WIN_USER="$DOTBASHCFG_WIN_USER"
export DOTBASHCFG_DATA_DIR="$DOTBASHCFG_DATA_DIR"
export DOTBASHCFG_TOOLS_DIR="$DOTBASHCFG_DATA_DIR/tools"
export DOTBASHCFG_MAIL="$DOTBASHCFG_MAIL"
EOC

  # Source the bashrc script
  # shellcheck source=bashrc
  source "$HOME/.bashrc"
}

# Locate and execute every dotbashconfig feature installation script that has
# been activated (based on this script's options).
install_features() {
  # Create a temporary named pipe
  # This pipe will be used to catch features output by 'analyze_feature' 
  # function on its file descriptor no. 3
  feature_pipe=$(mktemp -u)
  mkfifo "$feature_pipe"

  # Attach it to file descriptor 3, and unlink the file (not needed afterwards)
  exec 3<>"$feature_pipe"
  rm "$feature_pipe"

  # Establish the full list of features to install
  for install_script in */feature_mgr.sh; do
    # Check if the feature detected shall be installed
    feature=$(basename "$(dirname "$install_script")")
    if check_feature "$feature"; then
      # If so, look for any dependent feature(s)
      requested_features+=("$feature")
      analyze_feature "$feature"
      # Dependent features are output by 'analyze_feature' on FD no. 3
      while read -r -t 0 -u 3; do
	read -r -u 3 -a new_features_to_install
	features_to_install+=("${new_features_to_install[*]}")
      done
      features_to_install+=("$feature")
    fi
  done

  # Close the file descriptor once finished
  exec 3>&-

  # If the user validates the full list, then proceed with the actual
  # installation
  additional_features_to_install=("$(echo "${features_to_install[*]}" | \
    uniq_occurrences | without_excluded requested_features)")
  if [ -z "${additional_features_to_install[0]}" ] || ok_to \
    "Following features must be installed as dependencies: $(printf '\n- %s' "${additional_features_to_install[@]}")" \
    "Ok to install?"; then
    for feature in $(echo "${features_to_install[*]}" | uniq_occurrences); do
      install_feature "$feature"
      [ $? -ne 0 ] && features_in_error+=("$feature")
    done
    if [ -n "$features_in_error" ]; then
      printf "\nWARN: Some features could not be installed (see logs above):\n"
      for feature in "${features_in_error[@]}"; do echo "- $feature"; done
      return 2
    fi
  fi
}

# Check whether some feature shall be installed or not, based on the options 
# used when calling this init.sh script.
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

# Analyze features to install in order to check whether they depend on other 
# features.
# $1 - The feature to analyze
# 
# N.B. Dependent features detected are output onto file descriptor no. 3 to 
# avoid polluting either the stdout or stderr (since some messages are printed 
# by this function on those outputs)
analyze_feature() {
  local feature="$1"

  echo "Analyzing $feature feature..."
  dependencies="$(run_in_project "$feature/feature_mgr.sh" get-dependencies)"
  for dependency in $dependencies; do 
    analyze_feature "$dependency"
    echo "$dependency" >&3
  done
}

# Run the installation function of some dotbashconfig feature.
# $1 - The feature to install
install_feature() {
  local feature="$1"

  echo "Installing / Configuring $feature feature..."
  run_in_project "$feature/feature_mgr.sh" install
}


# -- Main program -- #

# Default variables
if [ -f "$DOTBASH_CFG_FILE" ]; then
  # shellcheck disable=SC1090
  # SC1090: the sourced file is built by this script
  source "$DOTBASH_CFG_FILE"
else
  DOTBASHCFG_WIN_USER=$USER
  DOTBASHCFG_DATA_DIR=~
fi

# Parse program options
parse_opts "$@"
run_in_project acknowledge_opts

# Run bash env initialization
echo "Init bash environment..."
run_in_project init

# Install each dotbashconfig feature
if ! [ "$SKIP_FEATURES_INSTALLATION" = true ]; then
  run_in_project install_features
fi

# Done!
if [ $? -eq 0 ]; then
  echo "Done! Enjoy bashing ;-)"
fi

