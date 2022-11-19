# SpaceVim related shell aliases

_SPACEVIM_USAGE="
Usage: spacevim <backup|restore|update|help> [<backup_file>]

Helper command that facilitates exporting / reimporting SpaceVim configuration
from one workstation to another, as well as updating an existing SpaceVim
installation.
"

_SPACEVIM_PATCH_USAGE="
Usage: spacevim-patch <bundle-url>

Helper command to replace a Vim bundle integrated into SpaceVim by its up-to-date
version cloned from its source GitHub repository.
"

spacevim() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Wrong syntax for spacevim command." >&2
    echo "$_SPACEVIM_USAGE" >&2
    return 1

  elif [ "$1" = help ]; then
    echo "$_SPACEVIM_USAGE"

  elif [ "$1" = backup ]; then
    if [ -z "$2" ]; then
      ark="$(readlink -f "$(pwd)")/spacevim-$(date +%Y.%m.%dT%H.%M.%S).tar.gz"
    elif [ -d "$2" ]; then
      ark="$(readlink -f "$2")/spacevim-$(date +%Y.%m.%dT%H.%M.%S).tar.gz"
    elif ! [ -d "$(dirname "$2")" ]; then
      echo "Parent folder $(dirname "$2") doesn't exist. Aborting." >&2
      return 1
    else
      ark="$(readlink -f "$2")"
    fi
    echo "Backuping SpaceVim into $ark"
    pushd "$HOME" > /dev/null || return 1
    trap "popd > /dev/null" RETURN
    tar cvzf "$ark" .local/share/fonts .SpaceVim/* .SpaceVim.d/* \
      .cache/vimfiles .cache/SpaceVim/{,conf/}*.json
    echo "Backup complete! Archive has been created here: $ark"

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
    echo "Restoring SpaceVim from $2"
    pushd "$HOME" > /dev/null || return 1
    trap "popd > /dev/null" RETURN
    rm -rf .SpaceVim/* .SpaceVim.d/* .cache/vimfiles
    tar xvzf "$ark"
    echo "Restoration complete!"

  elif [ "$1" = update ]; then
    git -C "$HOME"/.SpaceVim clean -xdf
    git -C "$HOME"/.SpaceVim checkout .
    git -C "$HOME"/.SpaceVim pull
    vim +SPUpdate +qall
    find "$HOME"/.SpaceVim/bundle -name .git -print0 | while read -r -d $'\0' bundle_git_dir; do
      bundle_dir="$(dirname "$bundle_git_dir")"
      echo "Updating $bundle_dir"
      git -C "$bundle_dir" clean -xdf
      git -C "$bundle_dir" checkout .
      git -C "$bundle_dir" pull
    done
    echo "Update complete!"

  else
    echo "Unknown spacevim command $1" >&2
    echo "$_SPACEVIM_USAGE" >&2
    return 1
  fi
}

spacevim-update-bundle() {
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Wrong syntax for spacevim command." >&2
    echo "$_SPACEVIM_PATCH_USAGE" >&2

  else
    bundle_url="$1"
    mapfile -t url_parts < <(echo "$bundle_url" | grep -Po '[^\/]+')
    bundle_name="${url_parts[-1]/%.git/}"

    if [ -d "$HOME/.SpaceVim/bundle/$bundle_name/.git" ]; then
      echo "The $bundle_name bundle is already managed under bundle/ as a Git repository."
      echo "Running an update instead..."
      git -C "$HOME/.SpaceVim/bundle/$bundle_name" pull
    else
      rm -rf "$HOME/.SpaceVim/bundle/$bundle_name"
      git clone "$bundle_url" "$HOME/.SpaceVim/bundle/$bundle_name"
    fi
    echo "Done! Bundle $bundle_name is up-to-date!"
  fi 
}

