#!/bin/bash

usage() {
  cat <<EOF

  Usage: install.sh (no arguments, no options)

  Warning! It is assumed that this script is launched
  from dotbashconfig project root directory !

EOF
}

install() {
  distro=`get_distro`
  if [ "$distro" = "winbash" ]; then
    # Link C: drive
    [ -L /c ] || sudo ln -s /mnt/c /c

    # Attempt to mount and link other drives
    win_build=$(systeminfo.exe /FO CSV | tail -1 | sed 's/"//g' | cut -d, -f3 | cut -d' ' -f4)
    if [ $win_build -gt 16176 ]; then
      for drive in {d..n}; do
	[ -d /mnt/$drive ] || sudo mkdir -p /mnt/$drive
	[ -L /$drive ] || sudo ln -s /mnt/$drive /$drive
	sudo mount -t drvfs ${drive^^}: /mnt/$drive 2>/dev/null
	[ $? -eq 0 ] && echo "\"${drive^^}:\" drive successfully mounted under /$drive"
      done
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

