#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

# Docker CE version tested with WSL
# See: https://github.com/Microsoft/WSL/issues/2291#issuecomment-383698720
WSL1_DOCKER_VERSION=17.09.0
LEGACY_DOCKER_COMPOSE_VERSION=1.29.2

_cleanup_ubuntu() {
  # Remove any previous version of Docker
  sudo apt-get -y remove docker{,-engine,.io,-doc,-compose{,-v2}} podman-docker containerd runc
}

_install_dependencies_ubuntu() {
  # Update the source listing
  sudo apt-get update

  # Ensure that you have the binaries needed to fetch repo listing
  sudo apt-get install -y ca-certificates curl gnupg2
}

_install_legacy_docker_compose() {
  dk_compose_bin_url="https://github.com/docker/compose/releases/download"
  dk_compose_bin_url+="/$LEGACY_DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"
  sudo curl -L "$dk_compose_bin_url" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

_finalize() {
  # Add the current user to the ‘docker’ group
  sudo usermod -aG docker "$USER"
}

install_rhel() {
  # Set up the repository
  if [ -f /etc/fedora-release ]; then dist_folder=fedora; else dist_folder=redhat; fi
  install_repo "https://download.docker.com/linux/$dist_folder/docker-ce.repo"

  # Install Docker Engine
  install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  _finalize
}

install_ubuntu() {
  _cleanup_ubuntu
  _install_dependencies_ubuntu

  # Fetch the repository listing from docker's site & add it
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  # Update source listing now that we've added Docker's repo
  sudo apt-get update
  # Install Docker 
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-{buildx,compose}-plugin

  _finalize
}

install_wsl() {
  if [ "$WSL_VERSION" -ge 2 ]; then
    install_ubuntu

    # See https://github.com/microsoft/WSL/discussions/4872#discussioncomment-99164
    for s in ip{,6}tables; do sudo update-alternatives --set "$s" "/usr/sbin/$s-legacy"; done

  else
    _cleanup_ubuntu
    _install_dependencies_ubuntu 

    sudo apt-get install -y apt-transport-https software-properties-common cgroupfs-mount
    docker_ce_pkg_name="docker-ce_$WSL1_DOCKER_VERSION~ce-0~ubuntu_amd64.deb"
    wget "https://download.docker.com/linux/ubuntu/dists/$(lsb_release -cs)/pool/stable/amd64/$docker_ce_pkg_name" -P /tmp/
    trap 'rm -f /tmp/docker-ce*.deb' EXIT
    sudo dpkg -i /tmp/docker-ce_$WSL1_DOCKER_VERSION~ce-0~ubuntu_amd64.deb
    sudo apt -y -f install
    _install_legacy_docker_compose
    _finalize
  fi
}

get_resources() {
  _get_installed_resource "$HOME/.docker/config.json"
}

main "$@"

