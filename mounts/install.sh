#!/bin/bash

# Minimum Windows build version required to mount drives
# using DRVFS type
_MIN_WIN_BUILD_FOR_DRVFS=16176

usage() {
  cat <<EOF

  Usage: install.sh (no arguments, no options)

  Warning! It is assumed that this script is launched
  from dotbashconfig project root directory !

EOF
}

install() {
  distro=`get_distro_type`
  if [ "$distro" = "winbash" ]; then
    # Link C: drive
    [ -L /c ] || sudo ln -s /mnt/c /c

    # Attempt to mount and link other drives
    win_build=$(systeminfo.exe /FO CSV | tail -1 | sed 's/"//g' | cut -d, -f3 | cut -d' ' -f4)
    if [ $win_build -gt $_MIN_WIN_BUILD_FOR_DRVFS ]; then
      for drive in {d..n}; do
	[ -d /mnt/$drive ] || sudo mkdir -p /mnt/$drive
	[ -L /$drive ] || sudo ln -s /mnt/$drive /$drive
	mount | grep -q /mnt/$drive || sudo mount -t drvfs ${drive^^}: /mnt/$drive 2>/dev/null
	[ $? -eq 0 ] && echo "\"${drive^^}:\" drive successfully mounted under /$drive"
      done
      echo "No more drives to mount."
    else
      echo "Your current Windows version ($win_build) is insufficient to perform DRVFS mounts."
      echo "(min Windows build version required: $_MIN_WIN_BUILD_FOR_DRVFS)."
    fi
  elif [ -n "$distro" ]; then
    echo "No mounts to configure for this distro."
  else
    echo "Unknown distro, cannot configure mounts..." >&2
  fi
}


# -- Main program -- #

if [[ $1 =~ (-h|--help) ]]; then
  usage; exit 0
elif [ -n "$1" ]; then
  usage; exit 1
else
  source ~/.bash/bash.d/distro.sh
  install
fi

