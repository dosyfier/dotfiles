#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_centos() {
  install_repo centos-release-scl epel-release
  _install_rh_git_29
  _configure
}

install_redhat() {
  install_repo rhel-server-rhscl-7-rpms
  _install_rh_git_29
  _configure
}

_install_rh_git_29() {
  install_packages rh-git29

  # Enable installed software collections
  scl enable rh-git29 bash
}

install_ubuntu() {
  install_repo git-core/ppa
  install_packages git gitk
  _configure
}

install_winbash() {
  install_ubuntu
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

