#!/bin/bash

install_repo() {
  repo="$1"
  source /etc/os-release
  if [ -f "/etc/apt/sources.list.d/${repo/\//-}-$UBUNTU_CODENAME.list" ]; then
    echo "Repo $repo already installed."
  else
    sudo apt-add-repository -y "ppa:$repo"
  fi
}

install_packages() {
  sudo apt-get install -y "$@"
  packs_not_yet_installed=()
  for pack in "$@"; do
    if ! dpkg -l "$pack" 2>/dev/null | grep -q '^ii'; then
      packs_not_yet_installed+=("$pack")
    fi
  done
  if [ "${#packs_not_yet_installed[@]}" -gt 0 ]; then
    sudo apt-get install -y "${packs_not_yet_installed[@]}"
  fi
}
