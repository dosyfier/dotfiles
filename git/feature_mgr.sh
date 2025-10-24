#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

install_rhel() {
  version_of_git_in_distrib="$(dnf repoquery git --qf "%{version}" -q)"
  if ! _is_current_git_more_recent_than "$version_of_git_in_distrib"; then
    install_packages git
  fi
  _configure
}

install_ubuntu() {
  version_of_git_in_distrib="$(apt-cache show git | grep Version | \
    sed -r 's/.*: [0-9]:([0-9\.]+).*/\1/' | sort | tail -n1)"
  if ! _is_current_git_more_recent_than "$version_of_git_in_distrib"; then
    install_repo git-core/ppa
    install_packages git gitk
  fi
  _configure
}

install_wsl() {
  install_ubuntu
}

_format_version_for_cmp() { 
  echo "$1" | sed 's|\.| |g' | xargs printf "%02d.%02d" 
}

_is_current_git_more_recent_than() {
  installed_git_version=$(git --version 2> /dev/null | awk '{ print $NF }')
  [ -n "$installed_git_version" ] && \
    [[ "$(_format_version_for_cmp "$installed_git_version")" > "$(_format_version_for_cmp "$1")" ]]
}

_configure() {
  if [ -e "$HOME/.gitconfig" ]; then
    (>&2 echo "Git config file already exists ($HOME/.gitconfig). Not overriding.")
  else
    ln -s "$FEATURE_ROOT"/config.gitconfig "$HOME/.gitconfig"
  fi
}

get_resources() {
  _get_installed_resource "$HOME/.gitconfig"
}

main "$@"

