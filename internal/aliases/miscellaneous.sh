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

