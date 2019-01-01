#!/bin/bash

install_repo() {
  install_packages "$1"
}

install_packages() {
  sudo yum install -y $@
}

