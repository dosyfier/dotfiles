#!/bin/bash

# shellcheck source=../internal/install-base.sh
FEATURE_ROOT="$(realpath "$(dirname "$0")")"
source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  if ! _is_installed; then
    install_repo centos-release-scl epel-release
    _install_rh_git_29
  fi
  _configure
}

install_redhat() {
  if ! _is_installed; then
    install_repo rhel-server-rhscl-7-rpms
    _install_rh_git_29
  fi
  _configure
}

_install_rh_git_29() {
  install_packages rh-git29

  # Enable installed software collections
  scl enable rh-git29 bash
}

install_ubuntu() {
  if ! _is_installed; then
    install_repo git-core/ppa
    install_packages git gitk
  fi
  _configure
}

install_winbash() {
  install_ubuntu
}

_format_version_for_cmp() { 
  echo "$1" | sed 's|\.| |g' | xargs printf "%02d.%02d" 
}

_is_installed() {
  installed_git_version=$(git --version 2> /dev/null | awk '{ print $NF }')
  if [ -n "$installed_git_version" ] && \
    [[ "$(_format_version_for_cmp "$installed_git_version")" > "$(_format_version_for_cmp "2.9")" ]]; then
    return 0
  else
    return 1
  fi
}

_configure() {
  if [ -e "$HOME/.gitconfig" ]; then
    (>&2 echo "Git config file already exists ($HOME/.gitconfig). Not overriding.")
  else
    cp "$FEATURE_ROOT"/config.gitconfig "$HOME/.gitconfig"
    sed -i "s|%DOTBASHCFG_USER%|$USER|g" "$HOME/.gitconfig"
    sed -i "s|%DOTBASHCFG_MAIL%|$DOTBASHCFG_MAIL|g" "$HOME/.gitconfig"
  fi
}

main "$@"

