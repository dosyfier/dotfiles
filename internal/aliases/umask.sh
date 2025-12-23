#!/bin/bash

# Umask settings

# By default, we want umask to get set. This sets it for non-login shell.
# Current threshold for system reserved uid/gids is 200
# You could check uidgid reservation validity in
# /usr/share/doc/setup-*/uidgid file
if [ $UID -gt 199 ] && [ "$(id -g)" = "$(id -u)" ]; then
    umask 002
else
    umask 022
fi

