#!/bin/bash

# Installing additional APT repositories

repos="git-core/ppa \
  brightbox/ruby-ng \
  jonathonf/vim"

for repo in $repos; do
  if ! [ -f "/etc/apt/sources.list.d/${repo/\//-}-trusty.list" ]; then
    sudo apt-add-repository -y ppa:$repo
  fi
done

sudo apt-get update


# Installing expected packages

packages="git
  gitk
  rsync
  ruby
  ruby-dev
  tmux
  tree
  vim"

printf "$packages" | xargs sudo apt-get install -y

