#!/bin/bash

# Install expected packages
packages="rh-git29 \
  rsync \
  ruby \
  tmux \
  tree"

echo "$packages" | xargs sudo yum install

# Enable installed software collections
scl enable rh-git29 bash
