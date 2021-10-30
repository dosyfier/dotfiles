#!/bin/bash

# Make sure that all remote branches have some local equivalent one
# and set each of them to track its remote associated origin.
git_fetch_remotes() {
  # Fetch remote branches and prune (delete) obsolete local branches 
  git fetch origin -p

  # Create new local branches accordingly
  local_branches="$(git branch -l | sed 's:\s*\(\*\)\?\s*::')"
  git branch -r | grep -Ev 'master$' | while read -r remote_b; do 
    local_b=${remote_b#origin/}
    if ! ( echo "$local_branches" | grep -Eq "^${local_b}$" ); then
      git branch "${local_b}" "${remote_b}"
    fi
  done
}

# Pull remote commits by stashing potential local unstaged modifications.
git_stash_n_pull() {
  repo_dir="$1"
  if [ -n "$repo_dir" ]; then opts="-C $repo_dir"; else opts=''; fi
  if git $opts diff --exit-code > /dev/null; then
    git $opts pull
  else
    git $opts stash && git $opts pull && git $opts stash pop
  fi
}

# Display git branch state (branch name or tag or commit ID)
git_branch_state() {
  # Doing this way since `git` command seems to ignore bash logical operators || or &&...
  state=$(git symbolic-ref HEAD --short 2>/dev/null)
  if [ -z "$state" ]; then state=$(git show -s --pretty='%D' 2>/dev/null | grep -Po 'tag: \K[^\s,]+'); fi
  if [ -z "$state" ]; then state=$(git show -s --pretty='%h' 2>/dev/null); fi
  echo "$state"
}

# Trigger this function on each new prompt entry to re-calculate
# Git branch state for the current working directory
git_prompt_command() {
  # shellcheck disable=SC2155 
  # Return code isn't used here
  local new_pwd="$(pwd)"
  if [ "$new_pwd" != "$DOTBASHCFG_LAST_PWD" ]; then
    if git rev-parse --is-inside-work-tree 2>/dev/null 1>&2; then
      # shellcheck disable=SC2034 
      # Variable DOTBASHCFG_GIT_BRANCH_STATE is used in EXTRA_PS1
      DOTBASHCFG_GIT_BRANCH_STATE="$(git_branch_state 2>/dev/null | sed 's/\(.\+\)/\(\1\)/')"
    else
      unset DOTBASHCFG_GIT_BRANCH_STATE
    fi
  fi
  DOTBASHCFG_LAST_PWD="$new_pwd"
}

# If a bash prompt is defined by a theme external to dotbashconfig (e.g. Bash-It's Powerline),
# then this alias script is ignored
if [ "$EXTERNAL_PROMPT_ENABLED" = true ]; then
  return
fi

# Using this function forces to reset the DOTBASHCFG_LAST_PWD var
# before each time git gets called. Otherwise, when switching branch
# without changing cwd (which happens quite often), git prompt would
# not be updated...
alias git="unset DOTBASHCFG_LAST_PWD; git"

PROMPT_COMMAND="git_prompt_command; $PROMPT_COMMAND"

# Set EXTRA_PS1 variable (used by dotbashconfig's bash_prompt.sh script)
# to display the current git branch state (branch name or tag or commit ID)
# shellcheck disable=SC2016 disable=SC2034
# (EXTRA_PS1 is a contribution to PS1, used by another script)
EXTRA_PS1='$(command -v git > /dev/null && echo "$DOTBASHCFG_GIT_BRANCH_STATE" )'

