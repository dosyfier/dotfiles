#!/bin/bash

# -- Constants -- #

DOTFILES_ENV_FILE=$HOME/.dotfiles.env

# Build this script's effective parent directory
# by resolving links and/or trailing ~
DOTFILES_DIR="$(readlink -f "$(dirname "$0")")"
DOTFILES_DIR="${DOTFILES_DIR/#\~/$HOME}"


# -- Utility functions -- #

# shellcheck source=internal/common-utils.sh
source "$DOTFILES_DIR/internal/common-utils.sh"
# shellcheck source=internal/options-utils.sh
source "$DOTFILES_DIR/internal/options-utils.sh"



# --- Installation algorithm -- #

# Take into account the values of options passed to this init script.
# N.B. As a prerequisite, those values have been pre-parsed by the "parse_args"
# function from the options-utils.sh script.
acknowledge_opts() {
  # If 'help' option was set, don't do anything more
  if [ -n "${DOTFILES_VALUES[help]}" ]; then
    run_in_project usage; exit 0
  fi

  DOTFILES_USER_DISPLAY_NAME=${DOTFILES_VALUES[user_display_name]:-$DOTFILES_USER_DISPLAY_NAME}
  DOTFILES_USER_MAIL=${DOTFILES_VALUES[user_mail]:-$DOTFILES_USER_MAIL}
  DOTFILES_TOOLS_DIR=${DOTFILES_VALUES[tools_dir]:-$DOTFILES_TOOLS_DIR}

  # Check exclusive options: with_features, all_features and skip_install
  nb_exclusive_opts="$(echo "${DOTFILES_VALUES[with_features]}" \
    "${DOTFILES_VALUES[all_features]}" \
    "${DOTFILES_VALUES[skip_install]}" | wc -w)"
  if [ "$nb_exclusive_opts" -gt 1 ]; then
    usage_error "Only one of the following options can be specified at once:" \
      "¤ ${DOTFILES_SHORT_OPTS[all_features]}|${DOTFILES_LONG_OPTS[all_features]}" \
      "¤ ${DOTFILES_SHORT_OPTS[skip_install]}|${DOTFILES_LONG_OPTS[skip_install]}" \
      "¤ ${DOTFILES_SHORT_OPTS[with_features]}|${DOTFILES_LONG_OPTS[with_features]}|${DOTFILES_EXTRA_OPTS[with_features]}"
  fi

  if [ -n "${DOTFILES_VALUES[with_features]}" ]; then
    for feature in ${DOTFILES_VALUES[with_features]//,/ }; do
      if [ -f "$feature"/feature_mgr.sh ]; then
        declare -g "RUN_${feature^^}_FEATURE=true"
      else
        usage_error "Requested feature '$feature' does not exist" \
          "Available features are:" \
          "$(available_features | fold -w 80 -s)"
      fi
    done
    AUTO_DOTFILES=true

  elif [ -n "${DOTFILES_VALUES[all_features]}" ]; then
    RUN_ALL_FEATURES=true
    AUTO_DOTFILES=true

  elif [ -n "${DOTFILES_VALUES[skip_install]}" ]; then
    SKIP_FEATURES_INSTALLATION=true
  fi
}

# Initializes dotfiles configuration
init() {
  # If this script isn't launched from dotfiles' dir, then force rebuilding
  # ~/.dotfiles from the actual dotfiles project directory
  echo "Init $HOME/.dotfiles..."
  if ! [ "$DOTFILES_DIR" = "$(readlink -f "$HOME/.dotfiles")" ]; then
    remove_or_abort "$HOME/.dotfiles"
    ln -s "$DOTFILES_DIR" "$HOME/.dotfiles"
  fi

  # Erase existing shell rc file, and warn the user about it first
  local real_rc_file="$DOTFILES_DIR/$SHELL/conf/${SHELL}rc"
  local link_rc_file="$HOME/.${SHELL}rc"
  echo "Init $link_rc_file..."
  if ! [ -e "$link_rc_file" ] || ! [ -L "$link_rc_file" ] || \
        ! [ "$real_rc_file" = "$(readlink -f "$link_rc_file")" ]; then
    remove_or_abort "$link_rc_file"
    ln -s "$real_rc_file" "$link_rc_file"
  fi

  # Create the data and tools directories if they don't exist
  if ! [ -d "$DOTFILES_TOOLS_DIR" ]; then
    mkdir -p "$DOTFILES_TOOLS_DIR"
  fi

  # Create an env file holding defined DOTFILES_* variables
  echo "Backup dotfiles env configuration into $DOTFILES_ENV_FILE..."
  cat > "$DOTFILES_ENV_FILE" <<-EOC
# Dotfiles environment file
# vim: set ft=bash

export DOTFILES_DIR="$DOTFILES_DIR"
export DOTFILES_WIN_USER="$(if command -v cmd.exe &>/dev/null; then
    cmd.exe /C "echo %USERNAME%" 2>/dev/null | sed 's/[[:space:]]*$//'
  else
    echo "$USER"
  fi)"
export DOTFILES_TOOLS_DIR="$DOTFILES_TOOLS_DIR"
export DOTFILES_USER_DISPLAY_NAME="$DOTFILES_USER_DISPLAY_NAME"
export DOTFILES_USER_MAIL="$DOTFILES_USER_MAIL"
export DOTFILES_ENABLE_EXTERNAL_PROMPT=false
EOC

  # Source the bashrc script
  # shellcheck source=bash/conf/bashrc
  source "$real_rc_file"
}

# Locate and execute every dotfiles feature installation script that has
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

  # If the user validates the full list...
  additional_features_to_install=("$(echo "${features_to_install[*]}" | \
    uniq_occurrences | without_excluded requested_features)")
  if [ -z "${additional_features_to_install[0]}" ] || ok_to \
    "Following features must be installed as dependencies: $(printf '\n- %s' "${additional_features_to_install[@]}")" \
    "Ok to install?"; then
    # ... then proceed with the actual installation
    for feature in $(echo "${features_to_install[*]}" | uniq_occurrences); do
      if ! install_feature "$feature"; then
        features_in_error+=("$feature")
      fi
    done
    if [ -n "${features_in_error[0]}" ]; then
      printf "\nWARN: Some features could not be installed (see logs above):\n"
      for feature in "${features_in_error[@]}"; do echo "- $feature"; done
      return 2
    fi

    # ... and update dotfiles environment cfg file
  else
    return 2
  fi
}

# Check whether some feature shall be installed or not, based on the options
# used when calling this init.sh script.
# $1 - The feature to check
check_feature() {
  feature="$1"
  is_a_default_feature=$(run_in_project "$feature/feature_mgr.sh" by-default; echo $?)
  if [ "$RUN_ALL_FEATURES" = true ]; then
    return "$is_a_default_feature"
  elif [ "$AUTO_DOTFILES" = true ]; then
    run_feature_var_name=RUN_${feature^^}_FEATURE
    [ "${!run_feature_var_name}" = true ]
  else
    [ "$is_a_default_feature" -eq 0 ] && ok_to "Install $feature feature?"
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

# Run the installation function of some dotfiles feature.
# $1 - The feature to install
install_feature() {
  local feature="$1"

  echo "Installing / Configuring $feature feature..."
  run_in_project "$feature/feature_mgr.sh" install

  # Update dotfiles env config, in order to permanently active
  # the feature just installed:
  # - read currently enabled features
  currently_enabled_features=($(awk \
    '/export DOTFILES_ENABLED_FEATURES=\(/{flag=1; next} /\)/{flag=0} flag' "$DOTFILES_ENV_FILE"))
  # - erase the current list from the env file
  sed -ri '/^export DOTFILES_ENABLED_FEATURES=(/,/^)$/d' "$DOTFILES_ENV_FILE"
  # - and rewrite it
  currently_enabled_features+=("$feature")
  echo "export DOTFILES_ENABLED_FEATURES=($(echo "${currently_enabled_features[*]}" | \
    uniq_occurrences))" >> "$DOTFILES_ENV_FILE"
}


# -- Main program -- #

# Default variables
if [ -f "$DOTFILES_ENV_FILE" ]; then
  # shellcheck disable=SC1090
  # SC1090: the sourced file is built by this script
  source "$DOTFILES_ENV_FILE"
else
  DOTFILES_WIN_USER=$USER
  DOTFILES_TOOLS_DIR=~/tools
fi

# Parse program options
parse_opts "$@"
run_in_project acknowledge_opts

# Run bash env initialization
echo "Init bash environment..."
run_in_project init

# Install each dotfiles feature
if ! [ "$SKIP_FEATURES_INSTALLATION" = true ]; then
  run_in_project install_features
fi

# Done!
if [ $? -eq 0 ]; then
  echo "Done! Enjoy bashing ;-)"
fi

