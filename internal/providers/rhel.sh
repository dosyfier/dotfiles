#!/bin/bash

# shellcheck disable=SC2034
# SC2034: This script is sourced (this variable is used by features' scripts)
OS_MAJOR_RELEASE=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's|"||g')

install_repo() {
  if command -v rpm-ostree &>/dev/null; then
    curl -sSfL "$1" | sudo tee "/etc/yum.repos.d/$(basename "$1")"
  else
    if ! command -v dnf-3 &>/dev/null; then
      install_packages dnf-plugins-core
    fi
    dnf_cfg_mgr_cmd="$(command -v dnf-3 dnf | head -n1 | xargs basename)"
    sudo "$dnf_cfg_mgr_cmd" config-manager --add-repo "$1"
  fi
}

install_packages() {
  packs_not_yet_installed=()
  for pack in "$@"; do
    if ! rpm -qi "$pack" &> /dev/null; then
      packs_not_yet_installed+=($pack)
    fi
  done
  if [ "${#packs_not_yet_installed[@]}" -gt 0 ]; then
    if command -v rpm-ostree &>/dev/null; then
      sudo rpm-ostree install "${packs_not_yet_installed[@]}"
    else
      sudo dnf install -y "${packs_not_yet_installed[@]}"
    fi
  fi
}
