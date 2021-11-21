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
  * get-dependencies	Displays the list of features this feature depends on.
  * by-default		Indicates (by its exit code) whether the feature shall be installed or not by
			default on the current machine (depending on its config, OS version, etc.)
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

shall_be_installed_by_default() {
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
  
  # Because of set -e done in each feature_mgr.sh script, the `install_function` must be called from
  # an "if" block, so that we can display an indicative message in case of an installation failure
  if "${install_function}"; then
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
  elif [ "$1" = "by-default" ]; then
    _init_env
    shall_be_installed_by_default
  else
    usage; exit 1
  fi
}

