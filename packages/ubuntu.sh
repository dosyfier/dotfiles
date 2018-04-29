#!/bin/bash

# Installing additional APT repositories

repos="git-core/ppa \
  brightbox/ruby-ng"

for repo in $repos; do
  if ! [ -f "/etc/apt/sources.list.d/${repo/\//-}-trusty.list" ]; then
    sudo apt-add-repository -y ppa:$repo
    repo_added=true
  fi
done

[ "$repoadded" = true ] && sudo apt-get update


# Installing expected packages

packages="git
  gitk
  rsync
  ruby
  tmux
  tree"

printf "$packages" | xargs sudo apt-get install -y

