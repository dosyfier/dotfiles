#!/bin/bash

# Minimum Windows build version required to mount drives
# using DRVFS type
_MIN_WIN_BUILD_FOR_DRVFS=16176

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_winbash() {
  # Link C: drive
  [ -L /c ] || sudo ln -s /mnt/c /c

  # Attempt to mount and link other drives
  win_build=$(get_win_build_nb)
  if [ "$win_build" -gt $_MIN_WIN_BUILD_FOR_DRVFS ]; then
    for drive in {d..n}; do
      [ -d /mnt/$drive ] || sudo mkdir -p /mnt/$drive
      [ -L /$drive ] || sudo ln -s /mnt/$drive /$drive
      mount | grep -q /mnt/$drive || sudo mount -t drvfs ${drive^^}: /mnt/$drive 2>/dev/null \
	&& echo "\"${drive^^}:\" drive successfully mounted under /$drive"
    done
    echo "No more drives to mount."
  else
    echo "Your current Windows version ($win_build) is insufficient to perform DRVFS mounts."
    echo "(min Windows build version required: $_MIN_WIN_BUILD_FOR_DRVFS)."
  fi
}

main "$@"

