#!/bin/bash
# shellcheck disable=SC1090
# SC1090: This script sources scripts with variable file names

# This is a base script meant to be sourced by any dotfiles feature
# installation script.

set -euo pipefail

if [ "${DEBUG:-false}" = true ]; then
  set -x
fi

DOTFILES_ENV_FILE=$HOME/.dotfiles.env
DOTFILES_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
DOTFILES_INTERNAL_ROOT="$DOTFILES_DIR/internal"
DOTFILES_FEATURE=$(basename "$(readlink -f "$(dirname "$0")")")

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
  if [ -f "$DOTFILES_ENV_FILE" ]; then
    source "$DOTFILES_ENV_FILE"
  else
    echo "Unable to install the $DOTFILES_FEATURE feature. Missing config file $DOTFILES_ENV_FILE"
    exit 2
  fi
  source "$DOTFILES_INTERNAL_ROOT/common-utils.sh"
  source "$DOTFILES_INTERNAL_ROOT/aliases/distro.sh"
}

get_dependencies() {
  return 0
}

shall_be_installed_by_default() {
  return 0
}

get_resources() {
  return 0
}

_get_installed_resource() {
  if [ $# -eq 0 ]; then
    echo "Usage: _get_installed_resource <file_or_dir> [<file_or_dir>]*" >&2
    return 1
  else
    for resource in "$@"; do
      if [ -e "$resource" ]; then echo "$resource"; fi
    done
  fi
}

install() {
  distro=$(get_distro_type)
  if type "install_${distro}" 1>/dev/null 2>&1; then
    run_install "install_${distro}" "$distro"
  elif type "install_common" 1>/dev/null 2>&1; then
    run_install "install_common" "$distro"
  elif [ -n "$distro" ]; then
    echo "Nothing to install for this distro for the $DOTFILES_FEATURE feature."
  else
    echo "Unknown distro, cannot install packages for the $DOTFILES_FEATURE feature..." >&2
    return 1
  fi
}

run_install() {
  install_function="$1"
  distro="$2"

  if [ -f "$DOTFILES_INTERNAL_ROOT/providers/${distro}.sh" ]; then
    source "$DOTFILES_INTERNAL_ROOT/providers/${distro}.sh"
  fi
  
  # Because of set -e done in each feature_mgr.sh script, the `install_function` must be called from
  # an "if" block, so that we can display an indicative message in case of an installation failure
  # Note: Putting ${install_function} in an if block prevents the set -e option from working as expected.
  # Hence the use of a subshell construct
  set +eu; ( set -euo pipefail; "${install_function}"; ); rc=$?; set -eu
  if [ $rc -eq 0 ]; then
    echo "Feature $DOTFILES_FEATURE successfully installed."
  else
    echo "Feature $DOTFILES_FEATURE could not be installed (see above)."
    return 2
  fi
}

update() {
  install
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
  elif [ "$1" = "get-resources" ]; then
    _init_env
    get_resources
  elif [ "$1" = "update" ]; then
    _init_env
    update
  else
    usage; exit 1
  fi
}

