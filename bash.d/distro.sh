#!/bin/bash

get_distro() {
  if [ -f /etc/centos-release ]; then
    echo "centos"
  elif [ -f /etc/redhat-release ]; then
    echo "redhat"
  else
    proc_name=$(cat /proc/version | awk '{ print $1 }')
    case $proc_name in
      MINGW*)
        echo "mingw"
        ;;
      CYGWIN*) 
        echo "cygwin"
        ;;
      Linux*)
        if grep -Fq Microsoft /proc/version; then
          echo "winbash"
        else
          echo "Unknown distro... /proc/version says: $proc_name" >&2
          return 1
        fi
        ;;
      *)
        echo "Unknown distro... /proc/version says: $proc_name" >&2
        return 1
        ;;
    esac
  fi
}

create_drive_links() {
  for dir in $drive_mount_root/*; do
    dir_basename=$(basename $dir)
    [ -L /$dir_basename ] || ln -s $dir /$dir_basename
  done
}

case `get_distro` in
  mingw64)
    win_os=true
    ;;
  cygwin)
    win_os=true
    drive_mount_root=/cygdrive
    alias cygwin_setup="$DOTBASHCFG_DATA_DIR/utils/cygwin64/setup-x86_64.exe"
    ;;
  winbash)
    win_os=true
    drive_mount_root=/mnt
    ;;
  *)
    ;;
esac

if [ "$win_os" = true ]; then
  WIN_HOSTS="/c/Windows/System32/drivers/etc/hosts"
  WIN_HOME="/c/Users/$DOTBASHCFG_USER"
  WIN_DOWNLOADS="$WIN_HOME/Downloads"
  OFFICE_ROOT="/c/Program Files (x86)/Microsoft Office/Office15"

  alias excel='"$OFFICE_ROOT/EXCEL.EXE"'
  alias onenote='"$OFFICE_ROOT/ONENOTE.EXE"'
  alias outlook='"$OFFICE_ROOT/OUTLOOK.EXE"'
  alias powerpoint='"$OFFICE_ROOT/POWERPNT.EXE"'
  alias winword='"$OFFICE_ROOT/WINWORD.EXE"'
fi
