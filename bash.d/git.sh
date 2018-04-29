#!/bin/bash

# Make sure that all remote branches have some local equivalent one
# and set each of them to track its remote associated origin.
git_fetch_remotes() {
  git fetch origin -p
  git branch -r | egrep -v 'master$' | while read remote_b; do git branch -f --track "${remote_b#origin/}" "$remote_b"; done
}
export git_fetch_remotes

# Display git branch name
git_branch_name() {
  git symbolic-ref HEAD --short 2> /dev/null
}

EXTRA_PS1='$(git_branch_name | sed '"'"'s/\(\S\+\)/\(\1\)/'"'"')'

