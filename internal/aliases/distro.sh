#!/bin/bash
# shellcheck disable=SC2034
# SC2034: This script is meant to be sourced through .bashrc. Thus, there is no
#   need to export any global variable.

source ~/.dotbashcfg

get_distro_type() {
  if [ -f /etc/centos-release ]; then
    echo "centos"
  elif [ -f /etc/redhat-release ]; then
    echo "redhat"
  else
    proc_name=$(awk '{ print $1 }' < /proc/version)
    case $proc_name in
      MINGW*)
        echo "mingw"
        ;;
      CYGWIN*) 
        echo "cygwin"
        ;;
      Linux*)
        if grep -qi Microsoft /proc/version; then
          echo "wsl"
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
  for dir in "$drive_mount_root"/*; do
    dir_basename=$(basename "$dir")
    [ -L "/$dir_basename" ] || ln -s "$dir" "/$dir_basename"
  done
}

version_lte() {
  [  "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

case $(get_distro_type) in
  mingw64)
    win_os=true
    ;;
  cygwin)
    win_os=true
    drive_mount_root=/cygdrive
    # shellcheck disable=SC2139
    # SC2139: Ok to expand when defined, not when used
    alias cygwin_setup="$DOTBASHCFG_TOOLS_DIR/cygwin64/setup-x86_64.exe"
    ;;
  wsl)
    win_os=true
    drive_mount_root=/mnt
    kernel_release_major="$(grep -Po '^[0-9]+' <(uname -r))"
    kernel_release_minor="$(grep -Po '^[0-9]+\.\K[0-9]+' <(uname -r))"
    if [ $((kernel_release_major*1000 + kernel_release_minor)) -ge 4019 ]; then
      # WSL 2 shows a Linux kernel with version higher than 4.19
      # Source: https://devblogs.microsoft.com/commandline/shipping-a-linux-kernel-with-windows/
      WSL_VERSION="2" 
      HYPERV_ADAPTER_IP="$(grep nameserver /etc/resolv.conf | awk '{print $2; exit;}')"
      LINUX_IP="$(ifconfig | grep -Pzo 'eth0: [^\n]+\n\s*inet \K([\.0-9]+)' | sed 's/\x0//g')"
      DISPLAY="$HYPERV_ADAPTER_IP:0"
    else
      WSL_VERSION="1"
      DISPLAY="127.0.0.1:0"
    fi
    ;;
  *)
    ;;
esac

if [ "$win_os" = true ]; then
  WIN_HOSTS="/c/Windows/System32/drivers/etc/hosts"
  WIN_HOME="/c/Users/$DOTBASHCFG_WIN_USER"
  WIN_DOWNLOADS="$WIN_HOME/Downloads"
  WIN_DESKTOP="$WIN_HOME/Desktop"
  OFFICE_ROOT="/c/Program Files (x86)/Microsoft Office/Office15"

  alias excel='"$OFFICE_ROOT/EXCEL.EXE"'
  alias onenote='"$OFFICE_ROOT/ONENOTE.EXE"'
  alias outlook='"$OFFICE_ROOT/OUTLOOK.EXE"'
  alias powerpoint='"$OFFICE_ROOT/POWERPNT.EXE"'
  alias winword='"$OFFICE_ROOT/WINWORD.EXE"'

  reg_query() {
    if [ -z "$2" ]; then 
      reg.exe query "${1//\//\\}"
    else
      reg.exe query "${1//\//\\}" /v "$2"
    fi \
      | awk 'NR==3 { print $NF }'
  }

  get_win_version() {
    reg_query 'HKLM/SOFTWARE/Microsoft/Windows NT/CurrentVersion/' ReleaseId
  }
  get_win_build_nb() {
    reg_query 'HKLM/SOFTWARE/Microsoft/Windows NT/CurrentVersion/' CurrentBuildNumber
  }

  # Export environment variables required to launch Terminator via a VBS script
  export WIN_HOME DISPLAY
fi

