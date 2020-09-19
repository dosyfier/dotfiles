#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"
GIT_SCL_VERSION=2.18

install_centos() {
  if ! _is_installed; then
    install_repo centos-release-scl epel-release
    _install_rh_git
  fi
  _configure
}

install_redhat() {
  if ! _is_installed; then
    install_repo rhel-server-rhscl-7-rpms
    _install_rh_git
  fi
  _configure
}

_install_rh_git() {
  install_packages rh-git${GIT_SCL_VERSION//\./}

  # Enable installed software collections
  scl enable rh-git${GIT_SCL_VERSION//\./} bash
}

install_ubuntu() {
  if ! _is_installed; then
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

_is_installed() {
  installed_git_version=$(git --version 2> /dev/null | awk '{ print $NF }')
  if [ -n "$installed_git_version" ] && \
    [[ "$(_format_version_for_cmp "$installed_git_version")" > "$(_format_version_for_cmp "$GIT_SCL_VERSION")" ]]; then
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

