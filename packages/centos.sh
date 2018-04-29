#!/bin/bash

# Install supplementary YUM repositories for CentOS
sudo yum install centos-release-scl epel-release

# Install packages based on YUM
`dirname $0`/providers/yum_install.sh
