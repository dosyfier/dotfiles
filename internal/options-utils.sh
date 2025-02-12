#!/bin/bash

# shellcheck source=aliases/colors.sh
source "$DOTFILES_DIR/internal/aliases/colors.sh"

available_features() {
  find "$DOTFILES_DIR" -maxdepth 2 -name feature_mgr.sh -printf "%h, " | \
    sed -e "s#$DOTFILES_DIR/##g" -e 's#, $##g'
}

declare -A DOTFILES_SHORT_OPTS
declare -A DOTFILES_LONG_OPTS
declare -A DOTFILES_EXTRA_OPTS
declare -A DOTFILES_ARG_NAMES
declare -A DOTFILES_DESCS
declare -A DOTFILES_VALUES

DOTFILES_SHORT_OPTS[user_display_name]="-n"
DOTFILES_LONG_OPTS[user_display_name]="--display-name"
DOTFILES_ARG_NAMES[user_display_name]="<login>"
DOTFILES_DESCS[user_display_name]="Display name (first & last name) "\
"to consider for the current user (used for \"git\" feature)."

DOTFILES_SHORT_OPTS[user_mail]="-m"
DOTFILES_LONG_OPTS[user_mail]="--mail"
DOTFILES_ARG_NAMES[user_mail]="<mail-address>"
DOTFILES_DESCS[user_mail]="Mail address to consider for the current "\
"user (used for \"git\" feature)."

DOTFILES_SHORT_OPTS[tools_dir]="-t"
DOTFILES_LONG_OPTS[tools_dir]="--tools"
DOTFILES_ARG_NAMES[tools_dir]="<tools-dir>"
DOTFILES_DESCS[tools_dir]="Path where any 3rd party tool required "\
"by Dotbashconfig will be installed."

DOTFILES_SHORT_OPTS[with_features]="-f"
DOTFILES_LONG_OPTS[with_features]="--with-features"
DOTFILES_EXTRA_OPTS[with_features]="--with-<feature-name>-feature"
DOTFILES_ARG_NAMES[with_features]="<feature-1>,...,<feature-n>"
DOTFILES_DESCS[with_features]='Automatically install only a '\
'subset of the dotbashconfig features (identified by their "feature-name"). '\
$'Here is the list of those features:\n'\
"$(available_features)"

DOTFILES_SHORT_OPTS[all_features]="-y"
DOTFILES_LONG_OPTS[all_features]="--all-features"
DOTFILES_DESCS[all_features]='Automatically accept the '\
'installation of every dotbashconfig features.'

DOTFILES_SHORT_OPTS[skip_install]="-s"
DOTFILES_LONG_OPTS[skip_install]="--skip-installation"
DOTFILES_DESCS[skip_install]='Skip the installation of every '\
'dotbashconfig features (i.e. only bashrc environment will be configured).'

DOTFILES_SHORT_OPTS[help]="-h"
DOTFILES_LONG_OPTS[help]="--help"
DOTFILES_DESCS[help]='Displays this message.'

usage() {
  usage_str="
  Usage: init.sh [options] 
  where available options are:
"

  for opt in "${!DOTFILES_SHORT_OPTS[@]}"; do
    short_opt="${DOTFILES_SHORT_OPTS[$opt]}"
    long_opt="${DOTFILES_LONG_OPTS[$opt]}"
    extra_opt="${DOTFILES_EXTRA_OPTS[$opt]}"
    arg_name="${DOTFILES_ARG_NAMES[$opt]}"
    description="${DOTFILES_DESCS[$opt]}"

    if [ -z "$arg_name" ]; then
      usage_str+=$'\n  '"$short_opt|$long_opt"
    else
      usage_str+=$'\n  '"$short_opt $arg_name"
      usage_str+=$'\n  '"$long_opt $arg_name"
    fi
    if [ -n "$extra_opt" ]; then
      usage_str+=$'\n  '"$extra_opt"
    fi
    usage_str+=$'\n'"$(echo "$description" | fold -w 80 -s | sed 's/^/        /g')"$'\n'
  done

  echo "$usage_str"
}

parse_opts() {
  while [ $# -ne 0 ]; do
    if m="$(match_regular "$1")"; then
      if [ -z "${DOTFILES_ARG_NAMES[$m]}" ]; then
	DOTFILES_VALUES[$m]=true
      elif [ -z "$2" ]; then
	usage_error "Missing argument ${DOTFILES_ARG_NAMES[$m]} for option $1"
      else
	DOTFILES_VALUES[$m]="$2"
	shift
      fi
      shift

    elif m="$(match_extra "$1")"; then
      key="$(echo "$m" | cut -d' ' -f1)"
      value="$(echo "$m" | cut -d' ' -f2)"
      DOTFILES_VALUES[$key]="$value"
      shift

    else
      usage_error "Unknown option $1"
    fi
  done
}

match_regular() {
  for e in "${!DOTFILES_SHORT_OPTS[@]}"; do
    [ "$1" == "${DOTFILES_SHORT_OPTS[$e]}" ] && echo "$e" && return 0
  done
  for e in "${!DOTFILES_LONG_OPTS[@]}"; do
    [ "$1" == "${DOTFILES_LONG_OPTS[$e]}" ] && echo "$e" && return 0
  done
  return 1
}

match_extra() {
  for e in "${!DOTFILES_EXTRA_OPTS[@]}"; do
    regex="$(echo "${DOTFILES_EXTRA_OPTS[$e]}" | sed 's,<.\+>,.*,g')"
    regex_extract="$(echo "${DOTFILES_EXTRA_OPTS[$e]}" | sed 's,<.\+>,\\(.*\\),g')"
    [[ "$1" =~ $regex ]] && echo "$e $(expr "$1" : $regex_extract)" && return 0
  done
}

usage_error() {
  (>&2 echo -e "${Red}ERROR:${NC} $1")
  [ $# -gt 1 ] && (>&2 printf '%s\n' "${@:2}")
  usage
  exit 1
}

