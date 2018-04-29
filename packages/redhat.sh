#!/bin/bash

# Install supplementary YUM repositories for RedHat
sudo yum-config-manager --enable rhel-server-rhscl-7-rpms

# Install packages based on YUM
`dirname $0`/providers/yum_install.sh
