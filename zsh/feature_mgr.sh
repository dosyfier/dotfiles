#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
}

install_common() {
  install_packages zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  ln -vs "$FEATURE_ROOT"/conf/zshrc "$HOME"/.zshrc
  ln -vs "$FEATURE_ROOT"/conf/p10k.zsh "$HOME"/.p10k.zsh
}

get_resources() {
  _get_installed_resource "$HOME/.zshrc" \
    "$HOME/.oh-my-zsh" \
    "$HOME/.p10k.zsh"
}

main "$@"
