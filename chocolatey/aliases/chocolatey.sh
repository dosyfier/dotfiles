#!/bin/bash

DOTBASHCFG_CHOCO_CONFIG_DIR=~/.bash/chocolatey/conf
DOTBASHCFG_CHOCO_CONFIG_DEFAULT="$(cat $DOTBASHCFG_CHOCO_CONFIG_DIR/default-config.txt)"

_dotbashcfg_choco_inst_usage() {
  available_types="$(find "$DOTBASHCFG_CHOCO_CONFIG_DIR" -name "packages-*.config" | \
    sed 's/^.*-\([a-z]\+\)\..*$/\1/' | paste -sd ',' - | sed 's/,/, /g')"
  echo "Usage: dotbashcfg_choco_inst [TYPE]"
  echo "where TYPE may be: $available_types"
  echo "(default: $DOTBASHCFG_CHOCO_CONFIG_DEFAULT)"
  printf "\n"
}

dotbashcfg_choco_inst() {
  if [ $# -eq 1 ] && [[ "$1" =~ ^(-h|--help|-?)$ ]]; then
    _dotbashcfg_choco_inst_usage
    return
  elif [ $# -gt 1 ]; then
    _dotbashcfg_choco_inst_usage
    return 1
  fi

  type="${1:-$DOTBASHCFG_CHOCO_CONFIG_DEFAULT}"
  choco install "$(wslpath -w "$DOTBASHCFG_CHOCO_CONFIG_DIR/packages-${type}.config")"
}

dotbashcfg_choco_up() {
  if [ $# -eq 1 ] && [[ "$1" =~ ^(-h|--help|-?)$ ]]; then
    echo "Upgrades all Chocolatey packages installed (lit.: choco upgrade all)"
    printf "\n"
    return
  fi
  choco upgrade all
}
