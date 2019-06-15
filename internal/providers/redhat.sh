#!/bin/bash

# shellcheck disable=SC2034
# SC2034: This script is sourced (this variable is used by features' scripts)
OS_MAJOR_RELEASE=$(grep VERSION_ID /etc/os-release | cut -d= -f2 | sed 's|"||g')

install_repo() {
  sudo yum-config-manager --enable "$1"
}

install_packages() {
  sudo yum install -y "$@"
}
