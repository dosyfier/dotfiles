#!/bin/bash

# Make sure that all remote branches have some local equivalent one
# and set each of them to track its remote associated origin.
git_fetch_remotes() {
  git fetch origin -p
  git branch -r | egrep -v 'master$' | while read remote_b; do 
    git branch --set-upstream-to=$remote_b "${remote_b#origin/}"
  done
}

# Pull remote commits by stashing potential local unstaged modifications.
git_stash_n_pull() {
  if git diff --exit-code > /dev/null; then
    git pull
  else
    git stash && git pull && git stash pop
  fi
}

# Display git branch state (branch name or tag or commit ID)
git_branch_state() {
  git symbolic-ref HEAD --short || git show -s --pretty="%D, commit: %h"
}

# Trigger this function on each new prompt entry to re-calculate
# Git branch state for the current working directory
git_prompt_command() {
  local new_pwd="$(pwd)"
  if [ "$new_pwd" != "$DOTBASHCFG_LAST_PWD" ]; then
    if git rev-parse --is-inside-work-tree 2>/dev/null 1>&2; then
      DOTBASHCFG_GIT_BRANCH_STATE="$(git_branch_state 2>/dev/null | sed 's/\(.\+\)/\(\1\)/')"
    else
      unset DOTBASHCFG_GIT_BRANCH_STATE
    fi
  fi
  DOTBASHCFG_LAST_PWD="$new_pwd"
}
# Using this function forces to reset the DOTBASHCFG_LAST_PWD var
# before each time git gets called. Otherwise, when switching branch
# without changing cwd (which happens quite often), git prompt would
# not be updated...
alias git="unset DOTBASHCFG_LAST_PWD; git"

PROMPT_COMMAND="git_prompt_command; $PROMPT_COMMAND"

# Set EXTRA_PS1 variable (used by dotbashconfig's bash_prompt.sh script)
# to display the current git branch state (branch name or tag or commit ID)
EXTRA_PS1='$(command -v git > /dev/null && echo "$DOTBASHCFG_GIT_BRANCH_STATE" )'

