#!/bin/bash
# shellcheck disable=SC1090
# SC1090: This script sources scripts with variable file names

# This is a base script meant to be sourced by any dotbashconfig feature
# installation script.


DOTBASH_CFG_INTERNAL_ROOT="$(dirname "${BASH_SOURCE[0]}")"

usage() {
  cat <<EOF

  Usage: install.sh [options] <action>

  Possible options are:
  * -h|-?|--help    Displays this message.

  Possible actions are:
  * get_dependencies	Displays the list of features this feature depends on.
  * install		Installs this feature.

EOF
}

get_dependencies() {
  return 0
}

install() {
  distro=$(get_distro_type)
  if type "install_${distro}" 1>/dev/null 2>&1; then
    if [ -f "$DOTBASH_CFG_INTERNAL_ROOT/providers/${distro}.sh" ]; then
      source "$DOTBASH_CFG_INTERNAL_ROOT/providers/${distro}.sh"
    fi
    "install_${distro}"
    echo "Feature successfully installed."
  elif [ -n "$distro" ]; then
    echo "Nothing to install for this distro."
  else
    echo "Unknown distro, cannot install packages..." >&2
  fi
}


main() {
  while [ $# -ne 0 ] && [[ "$1" =~ ^- ]]; do
    case "$1" in
      "-h"|"-?"|"--help")
	usage; exit 0
	;;
      *)
	usage; exit 1
	;;
    esac
    shift
  done

  if [ $# -ne 1 ]; then
    usage; exit 1
  elif [ "$1" = "install" ]; then
    source ~/.bash/internal/aliases/distro.sh
    install
  elif [ "$1" = "get-dependencies" ]; then
    get_dependencies
  else
    usage; exit 1
  fi
}

