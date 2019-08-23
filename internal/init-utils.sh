#!/bin/bash

if [ -z "$DOTBASH_CFG_DIR" ]; then DOTBASH_CFG_DIR=$HOME/.bash; fi
source "$DOTBASH_CFG_DIR/internal/aliases/colors.sh"

available_features() {
  find "$DOTBASH_CFG_DIR" -maxdepth 2 -name feature_mgr.sh -printf "%h, " | \
    sed -e "s#$DOTBASH_CFG_DIR/##g" -e 's#, $##g'
}

declare -A DOTBASHCFG_SHORT_OPTS
declare -A DOTBASHCFG_LONG_OPTS
declare -A DOTBASHCFG_EXTRA_OPTS
declare -A DOTBASHCFG_ARG_NAMES
declare -A DOTBASHCFG_DESCS
declare -A DOTBASHCFG_VALUES

DOTBASHCFG_SHORT_OPTS[win_login]="-l"
DOTBASHCFG_LONG_OPTS[win_login]="--win-login"
DOTBASHCFG_ARG_NAMES[win_login]="<login>"
DOTBASHCFG_DESCS[win_login]="Login of the actual Windows account, "\
"to be used when installing dotbashconfig from some Shell environment run from "\
"Windows (e.g. Cygwin, Git Bash, WSL)."

DOTBASHCFG_SHORT_OPTS[email]="-m"
DOTBASHCFG_LONG_OPTS[email]="--email"
DOTBASHCFG_ARG_NAMES[email]="<mail-address>"
DOTBASHCFG_DESCS[email]="Mail address to consider for the current "\
"user (used e.g. to configure Git)."

DOTBASHCFG_SHORT_OPTS[data_dir]="-d"
DOTBASHCFG_LONG_OPTS[data_dir]="--data"
DOTBASHCFG_ARG_NAMES[data_dir]="<data-dir>"
DOTBASHCFG_DESCS[data_dir]="Optional path indicating the root of "\
"a directory holding any development project, 3rd party tool installation, IDE "\
"installation, etc. (used e.g. on Windows to find Cygwin installation path)."

DOTBASHCFG_SHORT_OPTS[with_features]="-f"
DOTBASHCFG_LONG_OPTS[with_features]="--with-features"
DOTBASHCFG_EXTRA_OPTS[with_features]="--with-<feature-name>-feature"
DOTBASHCFG_ARG_NAMES[with_features]="<feature-1>,...,<feature-n>"
DOTBASHCFG_DESCS[with_features]='Automatically install only a '\
'subset of the dotbashconfig features (identified by their "feature-name"). '\
$'Here is the list of those features:\n'\
"$(available_features)"

DOTBASHCFG_SHORT_OPTS[all_features]="-y"
DOTBASHCFG_LONG_OPTS[all_features]="--all-features"
DOTBASHCFG_DESCS[all_features]='Automatically accept the '\
'installation of every dotbashconfig features.'

DOTBASHCFG_SHORT_OPTS[skip_install]="-s"
DOTBASHCFG_LONG_OPTS[skip_install]="--skip-installation"
DOTBASHCFG_DESCS[skip_install]='Skip the installation of every '\
'dotbashconfig features (i.e. only bashrc environment will be configured).'

DOTBASHCFG_SHORT_OPTS[help]="-h"
DOTBASHCFG_LONG_OPTS[help]="--help"
DOTBASHCFG_DESCS[help]='Displays this message.'

usage() {
  usage_str="
  Usage: init.sh [options] 
  where available options are:
"

  for opt in "${!DOTBASHCFG_SHORT_OPTS[@]}"; do
    short_opt="${DOTBASHCFG_SHORT_OPTS[$opt]}"
    long_opt="${DOTBASHCFG_LONG_OPTS[$opt]}"
    extra_opt="${DOTBASHCFG_EXTRA_OPTS[$opt]}"
    arg_name="${DOTBASHCFG_ARG_NAMES[$opt]}"
    description="${DOTBASHCFG_DESCS[$opt]}"

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
      if [ -z "${DOTBASHCFG_ARG_NAMES[$m]}" ]; then
	DOTBASHCFG_VALUES[$m]=true
      elif [ -z "$2" ]; then
	usage_error "Missing argument ${DOTBASHCFG_ARG_NAMES[$m]} for option $1"
      else
	DOTBASHCFG_VALUES[$m]="$2"
	shift
      fi
      shift

    elif m="$(match_extra "$1")"; then
      key="$(echo "$m" | cut -d' ' -f1)"
      value="$(echo "$m" | cut -d' ' -f2)"
      DOTBASHCFG_VALUES[$key]="$value"
      shift

    else
      usage_error "Unknown option $1"
    fi
  done
}

match_regular() {
  for e in "${!DOTBASHCFG_SHORT_OPTS[@]}"; do
    [ "$1" == "${DOTBASHCFG_SHORT_OPTS[$e]}" ] && echo "$e" && return 0
  done
  for e in "${!DOTBASHCFG_LONG_OPTS[@]}"; do
    [ "$1" == "${DOTBASHCFG_LONG_OPTS[$e]}" ] && echo "$e" && return 0
  done
  return 1
}

match_extra() {
  for e in "${!DOTBASHCFG_EXTRA_OPTS[@]}"; do
    regex="$(echo "${DOTBASHCFG_EXTRA_OPTS[$e]}" | sed 's,<.\+>,.*,g')"
    regex_extract="$(echo "${DOTBASHCFG_EXTRA_OPTS[$e]}" | sed 's,<.\+>,\\(.*\\),g')"
    [[ "$1" =~ $regex ]] && echo "$e $(expr "$1" : $regex_extract)" && return 0
  done
}

usage_error() {
  (>&2 echo -e "${Red}ERROR:${NC} $1")
  [ $# -gt 1 ] && (>&2 printf '%s\n' "${@:2}")
  usage
  exit 1
}

