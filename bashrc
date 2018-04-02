#!/bin/bash

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return


read_ordered_scripts() {
  while read def_script && [ -n "$def_script" ]; do
    script_basename="`basename $def_script`"
    if [[ $read_scripts != *"$script_basename"* ]]; then
      source ~/.bash/bash.d/$script_basename
      read_scripts+="${read_scripts+ }$script_basename"
    fi
  done <<< "$1"
}

read_ordered_scripts "`cat ~/.bash/bash.d/order/earliest-scripts.txt`"
read_ordered_scripts "`ls ~/.bash/bash.d/* | egrep -v '/$' | grep -vFf ~/.bash/bash.d/order/latest-scripts.txt`"
read_ordered_scripts "`cat ~/.bash/bash.d/order/latest-scripts.txt`"

