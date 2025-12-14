#!/bin/bash

# Run the provided command & arguments into dotfiles project's directory
run_in_project() {
  pushd "$DOTFILES_DIR" >/dev/null || exit 1
  trap "if [ \$(dirs -p | wc -l) -gt 1 ]; then popd > /dev/null; fi" EXIT RETURN
  "$@"
}

# Ask the user for the deletion of the file or directory provided as argument:
# - If accepted, remove it and go on,
# - Otherwise, exit in error.
remove_or_abort() {
  path_to_remove="$1"
  if [ -e "$path_to_remove" ]; then
    if ok_to "Existing $path_to_remove detected..." "Override?"; then
      run_lenient_sudo rm -rf "$path_to_remove"
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
  # This command is telling awk which lines to print. The variable $0 holds the
  # entire contents of a line and "x[]" is an array memorizing occurrences.
  # So, for each line of the file, the node of the array x is incremented and
  # the line printed if the content of that node was not (!) previously set.
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

# Runs a given COTS installation or configuration command (provided as a list of arguments), and
# make use of sudo elevation **only when necessary**.
# Basically, sudo rights are considered as required here only if the targeted dir is outside current
# user's home, within a dir this user hasn't direct access permissions.
run_lenient_sudo() {
  if [ "${DOTFILES_GLOBAL_INSTALL:-}" != true ]; then
    # If dotfiles installation is user specific, there should be no reason to run
    # a sudo command to install a soft under a $HOME sub-directory.
    "$@"; return
  fi
  echo -n "Attempting to run following cmd with sudo: "
  printf '"%s" ' "$@"
  echo
  set +euo pipefail
  sudo "$@"
  rc=$?; set -euo pipefail
  if [ $rc -ne 0 ]; then
    echo "Trying to run without sudo instead."
    "$@"
  fi
}

# Entirely reset (empty and recreate) a given directory
# $1 - The directory to reset
reset_dir_with_parent() {
  dir_to_reset="$1"

  remove_or_abort "$dir_to_reset"
  ensure_dir_exists "$dir_to_reset"
}

# Make sure a given directory exists, and create it otherwise
# $1 - The directory existence of which shall be ensured
ensure_dir_exists() {
  dir_to_ensure="$1"

  if ! [ -d "$dir_to_ensure" ]; then
    run_lenient_sudo bash -c "mkdir -p '$dir_to_ensure'"
    run_lenient_sudo bash -c "chown -R '$(id -u):$(id -g)' '$dir_to_ensure'"
  fi
}
