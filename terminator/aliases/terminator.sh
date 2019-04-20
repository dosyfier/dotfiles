#!/bin/bash
export TERM=xterm-256color
if [ -f ~/.dir_colors ]; then
  eval $(dircolors ~/.dir_colors)
fi
