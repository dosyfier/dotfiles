#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &> /dev/null; then
    echo git
  fi
}

install_common() {
  # shellcheck source=../git/aliases/git.sh
  source "$DOTFILES_DIR/git/aliases/git.sh"

  _install_or_update_git_repo "https://github.com/Bash-it/bash-it.git" \
    "/opt/bash-it"
  _install_or_update_git_repo "https://github.com/romkatv/gitstatus.git" \
    "/opt/gitstatus"

  sed -ri 's/^(export DOTFILES_ENABLE_EXTERNAL_PROMPT=).*$/\1true/' "$DOTFILES_ENV_FILE"
}

_install_or_update_git_repo() {
  git_repo_url="$1"
  git_repo_dir="$2"
  if [ -e "$git_repo_dir" ]; then
    git_stash_n_pull "$git_repo_dir" pull
  else
    sudo git clone "$git_repo_url" "$git_repo_dir"
    sudo chown -R "$USER" "$git_repo_dir"
  fi
}

main "$@"

