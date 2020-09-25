#!/bin/bash -e

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  echo git
}

install_common() {
  # shellcheck source=../git/aliases/git.sh
  source "$DOTBASH_CFG_ROOT/git/aliases/git.sh"

  _install_or_update_git_repo "https://github.com/Bash-it/bash-it.git" \
    "/opt/bash-it"
  _install_or_update_git_repo "https://github.com/romkatv/gitstatus.git" \
    "/opt/gitstatus"
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

