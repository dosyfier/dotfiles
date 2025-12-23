#!/bin/bash

# Vagrant related shell aliases

if [ "${win_os:-}" = true ]; then
  export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
  if [ -v drive_mount_root ]; then
    export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="$drive_mount_root/c"
  fi
fi
