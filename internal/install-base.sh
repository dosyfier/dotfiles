#!/bin/bash
# shellcheck disable=SC1090
# SC1090: This script sources scripts with variable file names

# This is a base script meant to be sourced by any dotbashconfig feature
# installation script.


DOTBASH_CFG_ROOT="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
DOTBASH_CFG_INTERNAL_ROOT="$DOTBASH_CFG_ROOT/internal"
DOTBASH_CFG_FEATURE=$(basename "$(readlink -f "$(dirname "$0")")")

usage() {
  cat <<EOF

  Usage: feature_mgr.sh [options] <action>

  Possible options are:
  * -h|-?|--help    Displays this message.

  Possible actions are:
  * get_dependencies	Displays the list of features this feature depends on.
  * install		Installs this feature.

EOF
}

_init_env() {
  if [ -f "$HOME/.dotbashcfg" ]; then
    source "$HOME/.dotbashcfg"
  else
    echo "Unable to install the $DOTBASH_CFG_FEATURE feature. Missing config file $HOME/.dotbashcfg"
    exit 2
  fi
  source "$DOTBASH_CFG_INTERNAL_ROOT/aliases/distro.sh"
}

get_dependencies() {
  return 0
}

install() {
  distro=$(get_distro_type)
  if type "install_${distro}" 1>/dev/null 2>&1; then
    run_install "install_${distro}" "$distro"
  elif type "install_common" 1>/dev/null 2>&1; then
    run_install "install_common" "$distro"
  elif [ -n "$distro" ]; then
    echo "Nothing to install for this distro for the $DOTBASH_CFG_FEATURE feature."
  else
    echo "Unknown distro, cannot install packages for the $DOTBASH_CFG_FEATURE feature..." >&2
    return 1
  fi
}

run_install() {
  install_function="$1"
  distro="$2"

  if [ -f "$DOTBASH_CFG_INTERNAL_ROOT/providers/${distro}.sh" ]; then
    source "$DOTBASH_CFG_INTERNAL_ROOT/providers/${distro}.sh"
  fi
  "${install_function}"
  if [ $? -eq 0 ]; then
    echo "Feature $DOTBASH_CFG_FEATURE successfully installed."
  else
    echo "Feature $DOTBASH_CFG_FEATURE could not be installed (see above)."
    return 2
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
    _init_env
    install
  elif [ "$1" = "get-dependencies" ]; then
    _init_env
    get_dependencies
  else
    usage; exit 1
  fi
}

