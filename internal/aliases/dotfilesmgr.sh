_DOTFILESMGR_USAGE="
Usage: dotfilesmgr <backup|restore|update|help> [<backup_file>]

Helper command that facilitates exporting / reimporting Dotfiles
from one workstation to another, as well as updating an existing
Dotfiles installation.
"

dotfilesmgr() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Wrong syntax for dotfilesmgr command." >&2
    echo "$_DOTFILESMGR_USAGE" >&2
    return 1

  elif [ "$1" = help ]; then
    echo "$_DOTFILESMGR_USAGE"

  elif [ "$1" = backup ]; then
    if [ -z "$2" ]; then
      ark="$(readlink -f "$(pwd)")/dotfiles-$(date +%Y.%m.%dT%H.%M.%S).tar"
    elif [ -d "$2" ]; then
      ark="$(readlink -f "$2")/dotfiles-$(date +%Y.%m.%dT%H.%M.%S).tar"
    elif ! [ -d "$(dirname "$2")" ]; then
      echo "Parent folder $(dirname "$2") doesn't exist. Aborting." >&2
      return 1
    else
      ark="$(readlink -f "$2")"
    fi

    echo "Backuping Dotfiles into $ark"
    pushd "$HOME" > /dev/null || return 1
    trap "popd > /dev/null" RETURN
    tar -cvhf "$ark" .dotfiles*
    tar rvf "$ark" .*rc
    find . -mindepth 1 -maxdepth 1 \( -name '*_aliases' -o -name '*_aliases.d' \) -print0 \
      | xargs -r -0 tar rvf "$ark"
    for feature in "${DOTFILES_ENABLED_FEATURES[@]}"; do
      for resource in $(.dotfiles/"$feature"/feature_mgr.sh get-resources); do
        tar rvf "$ark" "${resource/#$HOME\//}"
      done
    done
    gzip "$ark"
    echo "Backup complete! Archive has been created here: ${ark}.gz"

  elif [ "$1" = restore ]; then
    if [ -z "$2" ]; then
      echo "Backup file is expected as 2nd argument for restore command" >&2
      return 1
    fi
    ark="$(readlink -f "$2")"
    if ! [ -f "$ark" ]; then
      echo "Backup file $2 doesn't exist. Aborting." >&2
      return 1
    fi

    echo "Restoring Dotfiles from $2"
    pushd "$HOME" > /dev/null || return 1
    trap "popd > /dev/null" RETURN
    # TODO Remove old resources
    tar xvzf "$ark"
    echo "Restoration complete!"

  elif [ "$1" = update ]; then
    for feature in "${DOTFILES_ENABLED_FEATURES[@]}"; do
      echo "Updating feature ${feature}..."
      if ! "$DOTFILES_DIR/$feature/feature_mgr.sh" update; then
        echo "Error when updating feature ${feature}. Aborting" >&2
        return 1
      fi
    done
    echo "Update complete!"

  else
    echo "Unknown dotfilesmgr command $1" >&2
    echo "$_DOTFILESMGR_USAGE" >&2
    return 1
  fi
}
