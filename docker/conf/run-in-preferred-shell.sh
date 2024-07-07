#!/bin/sh
if [ -f /bin/zsh ]; then
  exec /bin/zsh "$@"
elif [ -f /bin/bash ]; then
  exec /bin/bash "$@"
else
  exec /bin/sh "$@"
fi
