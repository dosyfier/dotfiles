#!/bin/bash

install_repo() {
  sudo yum-config-manager --enable "$1"
}

install_packages() {
  sudo yum install -y $@
}
