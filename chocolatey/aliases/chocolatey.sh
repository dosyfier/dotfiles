#!/bin/bash

# Chocolatey related shell aliases

DOTFILES_CHOCO_CONFIG_DIR="$DOTFILES_DIR/chocolatey/conf"
DOTFILES_CHOCO_CONFIG_DEFAULT="$(grep -ohE '[^[:space:]]+' \
  "$DOTFILES_CHOCO_CONFIG_DIR/default-config.txt")"

_dotfiles_choco_inst_usage() {
  available_types="$(find "$DOTFILES_CHOCO_CONFIG_DIR" -name "packages-*.config" | \
    sed 's/^.*-\([a-z]\+\)\..*$/\1/' | paste -sd ',' - | sed 's/,/, /g')"
  echo "Usage: dotfiles_choco_inst [TYPE]"
  echo "where TYPE may be: $available_types"
  echo "(default: $DOTFILES_CHOCO_CONFIG_DEFAULT)"
  printf "\n"
}

dotfiles_choco_inst() {
  if [ $# -eq 1 ] && [[ "$1" =~ ^(-h|--help|-?)$ ]]; then
    _dotfiles_choco_inst_usage
    return
  elif [ $# -gt 1 ]; then
    _dotfiles_choco_inst_usage
    return 1
  fi

  type="${1:-$DOTFILES_CHOCO_CONFIG_DEFAULT}"
  choco install "$(wslpath -w "$DOTFILES_CHOCO_CONFIG_DIR/packages-${type}.config")"
}

dotfiles_choco_up() {
  if [ $# -eq 1 ] && [[ "$1" =~ ^(-h|--help|-?)$ ]]; then
    echo "Upgrades all Chocolatey packages installed (lit.: choco upgrade all)"
    printf "\n"
    return
  fi
  choco upgrade all
}
