_DOTBASHMGR_USAGE="
Usage: dotbashmgr <backup|restore|update|help> [<backup_file>]

Helper command that facilitates exporting / reimporting DotBashConfig configuration
from one workstation to another, as well as updating an existing DotBashConfig
installation.
"

dotbashmgr() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Wrong syntax for dotbashmgr command." >&2
    echo "$_DOTBASHMGR_USAGE" >&2
    return 1

  elif [ "$1" = help ]; then
    echo "$_DOTBASHMGR_USAGE"

  elif [ "$1" = backup ]; then
    if [ -z "$2" ]; then
      ark="$(readlink -f "$(pwd)")/dotbashcfg-$(date +%Y.%m.%dT%H.%M.%S).tar"
    elif [ -d "$2" ]; then
      ark="$(readlink -f "$2")/dotbashcfg-$(date +%Y.%m.%dT%H.%M.%S).tar"
    elif ! [ -d "$(dirname "$2")" ]; then
      echo "Parent folder $(dirname "$2") doesn't exist. Aborting." >&2
      return 1
    else
      ark="$(readlink -f "$2")"
    fi

    echo "Backuping DotBashConfig into $ark"
    pushd "$HOME" > /dev/null || return 1
    trap "popd > /dev/null" RETURN
    tar -cvhf "$ark" .bash/ .dotbashcfg
    tar rvf "$ark" .bashrc 
    if [ -e .bash_aliases ]; then
      tar rvf "$ark" .bash_aliases
    fi
    if [ -e .bash_aliases.d ]; then
      tar rvf "$ark" .bash_aliases.d
    fi
    for feature in "${DOTBASHCFG_ENABLED_FEATURES[@]}"; do
      for resource in $(.bash/"$feature"/feature_mgr.sh get-resources); do
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

    echo "Restoring DotBashConfig from $2"
    pushd "$HOME" > /dev/null || return 1
    trap "popd > /dev/null" RETURN
    # TODO Remove old resources
    tar xvzf "$ark"
    echo "Restoration complete!"

  elif [ "$1" = update ]; then
    for feature in "${DOTBASHCFG_ENABLED_FEATURES[@]}"; do
      echo "Updating feature ${feature}..."
      if ! "$HOME"/.bash/"$feature"/feature_mgr.sh update; then
        echo "Error when updating feature ${feature}. Aborting" >&2
        return 1
      fi
    done
    echo "Update complete!"

  else
    echo "Unknown dotbashmgr command $1" >&2
    echo "$_DOTBASHMGR_USAGE" >&2
    return 1
  fi
}
