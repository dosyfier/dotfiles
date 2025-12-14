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
  # TODO: Skip package install if they are already present
  sudo apt-get install -y "$@"
}
