#!/bin/bash

install_repo() {
  repo="$1"
  if [ -f "/etc/apt/sources.list.d/${repo/\//-}-trusty.list" ]; then
    echo "Repo $repo already installed."
  else
    sudo apt-add-repository -y "ppa:$repo"
  fi
}

install_packages() {
  sudo apt-get install -y "$@"
}
