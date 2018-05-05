#!/bin/bash

# Make sure that all remote branches have some local equivalent one
# and set each of them to track its remote associated origin.
git_fetch_remotes() {
  git fetch origin -p
  git branch -r | egrep -v 'master$' | while read remote_b; do git branch -f --track "${remote_b#origin/}" "$remote_b"; done
}
export git_fetch_remotes

# Display git branch state (branch name or tag or commit ID)
git_branch_state() {
  git symbolic-ref HEAD --short 2> /dev/null || git show -s --pretty="%D, commit: %h" 2> /dev/null
}

# Set EXTRA_PS1 variable (used by dotbashconfig's bash_prompt.sh script)
# to display the current git branch state (branch name or tag or commit ID)
EXTRA_PS1='$(command -v git > /dev/null && ( git_branch_state | sed '"'"'s/\(.\+\)/\(\1\)/'"'"') )'

