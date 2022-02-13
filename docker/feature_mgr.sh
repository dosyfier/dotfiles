#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

# Docker CE version tested with WSL
# See: https://github.com/Microsoft/WSL/issues/2291#issuecomment-383698720
WSL1_DOCKER_VERSION=17.09.0

_cleanup_ubuntu() {
  # Remove any previous version of Docker
  sudo apt -y remove docker docker-engine docker.io containerd runc
  # Update the source listing
  sudo apt-get update

  # Ensure that you have the binaries needed to fetch repo listing
  sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common cgroupfs-mount
}

_finalize() {
  # Add the current user to the ‘docker’ group
  sudo usermod -aG docker "$USER"
}

install_ubuntu() {
  _cleanup_ubuntu

  # Fetch the repository listing from docker's site & add it
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  # Update source listing now that we've added Docker's repo
  sudo apt-get update
  # Install Docker 
  sudo apt-get install docker-ce docker-ce-cli containerd.io

  _finalize
}

install_wsl() {
  if [ "$WSL_VERSION" -ge 2 ]; then
    install_ubuntu

    # See https://github.com/microsoft/WSL/discussions/4872#discussioncomment-99164
    for s in ip{,6}tables; do sudo update-alternatives --set "$s" "/usr/sbin/$s-legacy"; done

  else
    _cleanup_ubuntu
    docker_ce_pkg_name="docker-ce_$WSL1_DOCKER_VERSION~ce-0~ubuntu_amd64.deb"
    wget "https://download.docker.com/linux/ubuntu/dists/$(lsb_release -cs)/pool/stable/amd64/$docker_ce_pkg_name" -P /tmp/
    trap 'rm -f /tmp/docker-ce*.deb' EXIT
    sudo dpkg -i /tmp/docker-ce_$WSL1_DOCKER_VERSION~ce-0~ubuntu_amd64.deb
    sudo apt -y -f install
  _finalize
  fi
}

main "$@"

