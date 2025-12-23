#!/bin/bash

# Miscellaneous aliases

BACKUP_SUFFIX=.bak

bak() {
  if [ $# -ne 1 ] || [ -z "$1" ]; then
    echo "Usage: bak <file>"
    printf '\n'
    echo "Creates a backup of <file> named <file>.$BACKUP_SUFFIX"
  else
    cp "$1" "$1$BACKUP_SUFFIX"
  fi
}

unbak() {
  if [ $# -ne 1 ] || [ -z "$1" ]; then
    echo "Usage: unbak <file>"
    printf '\n'
    echo "Deletes a backup <file> to restore the original one"
  else
    [[ "$1" =~ $BACKUP_SUFFIX$ ]] && bak_file=$1 || bak_file=$1$BACKUP_SUFFIX
    main_file="${bak_file%"$BACKUP_SUFFIX"}"
    if ! [ -f "$bak_file" ]; then
      echo "Backup file $bak_file doesn't exist. Nothing to do."
    elif [ -f "$main_file" ]; then
      REPLY=""
      while ! [[ $REPLY =~ ^(y|n)$ ]]; do
	msg="Main file $main_file still exists. Replace with ${bak_file}? [y/n] "
	if [ "$CURRENT_SHELL" = zsh ]; then read -r "?$msg"; else read -r -p "$msg"; fi
      done
      if [[ $REPLY =~ ^y$ ]]; then
	mv "$bak_file" "$main_file"
      fi
    else
	mv "$bak_file" "$main_file"
    fi
  fi
}

# Bash- and ZSH-compatible helper function that can be called after a pipeline statement
# in order to return with the status code of the n-th piped statement.
# $1 - The index of the piped statement which status code shall be returned.
#      (indices start at 0, as in Bash)
return_pipestatus() {
  # N.B. This must be the very first statement, so that we can handle zsh case.
  # In zsh, pipestatus array is reset as soon as a new shell statement is issued.
  pipestatus_dump=("${pipestatus[@]:-${PIPESTATUS[@]}}")
  index="$1"
  if [ "$CURRENT_SHELL" = "zsh" ]; then
    return "${pipestatus_dump[$((index+1))]}"
  else
    return "${pipestatus_dump[$index]}"
  fi
}
