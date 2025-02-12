#!/bin/bash

# Run the provided command & arguments into dotfiles project's directory
run_in_project() {
  pushd "$DOTFILES_DIR" >/dev/null || exit 1
  trap "popd > /dev/null" EXIT
  # shellcheck disable=SC2068
  # Array expansion is intended this way
  $@
}

# Ask the user for the deletion of the file or directory provided as argument:
# - If accepted, remove it and go on,
# - Otherwise, exit in error.
remove_or_abort() {
  path_to_remove="$1"
  rm_cmd_wrapper="${2:-}"
  if [ -e "$path_to_remove" ]; then
    if ok_to "Existing $path_to_remove detected..." "Override?"; then
      $rm_cmd_wrapper rm -rf "$path_to_remove"
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

