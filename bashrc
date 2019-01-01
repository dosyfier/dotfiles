#!/bin/bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


# --- Functions

read_ordered_scripts() {
  while read def_script && [ -n "$def_script" ]; do
    script_basename="$(basename "$def_script")"
    if [[ $read_scripts != *"$script_basename"* ]]; then
      source "$def_script"
      read_scripts+="${read_scripts+ }$script_basename"
    fi
  done <<< "$1"
}


# --- Script core

# First, evaluate any global scripts packaged with OS distribution
dist_sourced_scripts="/etc/bashrc /etc/bash.bashrc /etc/bash_completion"
for source in $dist_sourced_scripts; do
  ( [ -f "$source" ] || [ -L "$source" ] ) && source "$source"
done

# Then, evaluate dotbashconfig project's configuration script
if ! [ -f ~/.dotbashcfg ]; then
  echo "ERROR: missing ~/.dotbashcfg file!"
else
  source ~/.dotbashcfg
fi

# Once base scripts and configuration variables have been evaluated,
# run other scripts in the appropriated order
read_ordered_scripts "$(xargs -I % echo "$HOME/.bash/internal/aliases/%" < ~/.bash/internal/aliases/order/earliest-scripts.txt)"
read_ordered_scripts "$(find ~/.bash/internal/aliases/*.sh | egrep -v '/$' | grep -vFf ~/.bash/internal/aliases/order/latest-scripts.txt)"
read_ordered_scripts "$(find  ~/.bash/**/aliases/*.sh | egrep -v internal/)"
read_ordered_scripts "$(xargs -I % echo "$HOME/.bash/internal/aliases/%" < ~/.bash/internal/aliases/order/latest-scripts.txt)"

# Allow users to define supplementary aliases within ~/.bash_aliases (file or directory)
# These are evaluated as overriding scripts (i.e. once all other scripts have been processed)
if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
elif [ -d ~/.bash_aliases ]; then
  for script in ~/.bash_aliases/*; do source "$script"; done
fi

