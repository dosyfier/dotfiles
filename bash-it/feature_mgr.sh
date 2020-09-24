#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

BASH_IT_INSTALL_DIR=/opt/bash-it

get_dependencies() {
  echo git
}

install() {
  # shellcheck source=../git/aliases/git.sh
  source "$DOTBASH_CFG_ROOT/git/aliases/git.sh"

  if [ -e "$BASH_IT_INSTALL_DIR" ]; then
    git_stash_n_pull "$BASH_IT_INSTALL_DIR" pull
  else
    sudo git clone https://github.com/Bash-it/bash-it.git "$BASH_IT_INSTALL_DIR"
    sudo chown -R "$USER" "$BASH_IT_INSTALL_DIR"
  fi
}

main "$@"

