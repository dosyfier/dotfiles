# Distro-related shell aliases

# vim: set ft=bash

# shellcheck disable=SC2034
# SC2034: This script is meant to be sourced through .bashrc. Thus, there is no
#   need to export any global variable (except for Terminator Windows shortcut,
#   as explained below).

source ~/.dotbashcfg

# Read /proc/version, once and for all (due to performance issues on WSL 1)
PROC_VERSION=$(cat /proc/version)

get_distro_type() {
  if [ -f /etc/centos-release ]; then
    echo "centos"
  elif [ -f /etc/redhat-release ]; then
    echo "redhat"
  else
    case "$PROC_VERSION" in
      MINGW*)
        echo "mingw"
        ;;
      CYGWIN*) 
        echo "cygwin"
        ;;
      Linux*)
        if [[ "$PROC_VERSION" =~ [Mm]icrosoft ]]; then
          echo "wsl"
        elif [[ "$PROC_VERSION" =~ [Uu]buntu ]]; then
          echo "ubuntu"
        else
          echo "Unknown distro... /proc/version says: $PROC_VERSION" >&2
          return 1
        fi
        ;;
      *)
        echo "Unknown distro... /proc/version says: $PROC_VERSION" >&2
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

# N.B. Env variables used by Windows shortcut to launch Terminator need to be exported,
# hence some "export XX=YY" commands

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
    # We differentiate WSL2 from WSL1 via gcc version used (gcc v5.x for WSL1 vs. gcc v8 or higher for WSL2)
    # See: https://github.com/microsoft/WSL/issues/4555
    if [ "$(grep -oE 'gcc (version|\(GCC\)) ([0-9]+)' <<< "$PROC_VERSION" | awk '{print $3}')" -gt 5 ]; then
      WSL_VERSION="2" 
      if ! [ -v DISPLAY ]; then
        HYPERV_ADAPTER_IP="$(ip route | awk '/^default/{print $3; exit}')"
        LINUX_IP="$(ifconfig | grep -Pzo 'eth0: [^\n]+\n\s*inet \K([\.0-9]+)' | sed 's/\x0//g')"
        export DISPLAY="$HYPERV_ADAPTER_IP:0"
      fi
    else
      WSL_VERSION="1"
      export DISPLAY="127.0.0.1:0"
    fi
    ;;
  *)
    ;;
esac

if [ "$win_os" = true ]; then
  WIN_HOSTS="/c/Windows/System32/drivers/etc/hosts"
  export WIN_HOME="/c/Users/$DOTBASHCFG_WIN_USER"
  WIN_DOWNLOADS="$WIN_HOME/Downloads"
  WIN_DESKTOP="$WIN_HOME/Desktop"

  explorer() {
    # 2>/dev/null on "tr" command to avoid warnings about trailing '\' that
    # may break path portability
    # shellcheck disable=SC1003
    #   We are not trying to escape a ' quote, we just want to replace / by \
    if [ $# -eq 0 ]; then
      explorer.exe
    elif [ $# -eq 1 ]; then
      explorer.exe "$(wslpath -m "$(readlink -f "$1")" | tr '/' '\' 2>/dev/null)"
    else
      echo "Usage: explorer [<PATH>]" >&2; return 1
    fi
  }

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

  is_wslg_active() {
    ! { [ -d /mnt/wslg ] && [ -v DISPLAY ] && [ -v WAYLAND_DISPLAY ] && [ -v PULSE_SERVER ] ; }
  }

  firefox() {
    '/mnt/c/Program Files/Mozilla Firefox/firefox.exe' "$@"
  }
fi

