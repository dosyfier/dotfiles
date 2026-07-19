#!/bin/bash

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

NEOVIM_VERSION=0.12.4
NEOVIM_DOWNLOAD_URL="${GITHUB_PROXY_URL:-https://github.com}/neovim/neovim/releases/download/v$NEOVIM_VERSION/\
nvim-linux-x86_64.tar.gz"

FZF_VERSION=0.74.0
FZF_DOWNLOAD_URL="${GITHUB_PROXY_URL:-https://github.com}/junegunn/fzf/releases/download/v$FZF_VERSION/\
fzf-$FZF_VERSION-linux_amd64.tar.gz"

RG_VERSION=15.1.0
RG_DOWNLOAD_URL="${GITHUB_PROXY_URL:-https://github.com}/BurntSushi/ripgrep/releases/download/$RG_VERSION/\
ripgrep-$RG_VERSION-x86_64-unknown-linux-musl.tar.gz"

VALE_VERSION=3.13.1
VALE_DOWNLOAD_URL="${GITHUB_PROXY_URL:-https://github.com}/errata-ai/vale/releases/download/v$VALE_VERSION/\
vale_${VALE_VERSION}_Linux_64-bit.tar.gz"

LAZY_NVIM_VERSION=11.17.5
LAZY_NVIM_DOWNLOAD_URL="${GITHUB_PROXY_URL:-https://github.com}/folke/lazy.nvim/archive/refs/tags/\
v${LAZY_NVIM_VERSION}.tar.gz"


# shellcheck source=aliases/neovim.sh
source "$(dirname "$0")/aliases/neovim.sh"

get_dependencies() {
  if ! command -v git > /dev/null 2>&1; then
    echo git
  fi
  if ! command -v npm > /dev/null 2>&1; then
    echo nodejs
  fi
}

_download_and_install() {
  # C compiler is needed at least for Treesitter plugin
  install_packages gcc

  reset_dir_with_parent "$NEOVIM_HOME"
  run_lenient_sudo bash -c "curl -sSfL --netrc '$NEOVIM_DOWNLOAD_URL' | \
tar --strip-components=1 -C '$NEOVIM_HOME' -xz"

  local_bin_dir="$DOTFILES_LOCAL_DIR/bin"
  ensure_dir_exists "$local_bin_dir"

  run_lenient_sudo bash -c "curl -sSfL --netrc '$FZF_DOWNLOAD_URL' | tar -C '$local_bin_dir' -xz"
  run_lenient_sudo bash -c "curl -sSfL --netrc '$RG_DOWNLOAD_URL' | \
tar -C '$local_bin_dir' -xz --strip-components=1 ripgrep-$RG_VERSION-x86_64-unknown-linux-musl/rg"
  run_lenient_sudo bash -c "curl -sSfL --netrc '$VALE_DOWNLOAD_URL' | tar -C '$local_bin_dir' -xz vale"

  # When running behind a corporate proxy with limited internet / GitHub access,
  # specific actions need to be done manually before launching LazyVim for the 1st time
  if [ -n "${GITHUB_PROXY_URL:-}" ]; then
    # Manually install Lazy.NVim
    lazy_nvim_install_dir="$DOTFILES_LOCAL_DIR/share/nvim/lazy/lazy.nvim" 
    reset_dir_with_parent "$lazy_nvim_install_dir"
    run_lenient_sudo bash -c "curl -sSfL --netrc '$LAZY_NVIM_DOWNLOAD_URL' | \
      tar -xz --strip-components=1 -C '$lazy_nvim_install_dir'"

    # Patch it to make it download NeoVim plugins as source code archives instead of
    # cloning the associated git repositories
    patch "$lazy_nvim_install_dir/lua/lazy/manage/task/git.lua" \
      "$FEATURE_ROOT/conf/patches/lazy_nvim_git_tasks.lua.patch"

    # Bootstrap a dummy git repository for Lazy.NVim to avoid recurrent warnings
    run_lenient_sudo bash -c "git init '$lazy_nvim_install_dir'"
    run_lenient_sudo bash -c "git -C '$lazy_nvim_install_dir' add -A"
    run_lenient_sudo bash -c "git -C '$lazy_nvim_install_dir' commit -m 'Version $LAZY_NVIM_VERSION'"
    run_lenient_sudo bash -c "git -C '$lazy_nvim_install_dir' tag '$LAZY_NVIM_VERSION'"
    run_lenient_sudo bash -c "git -C '$lazy_nvim_install_dir' remote add origin https://github.com/folke/lazy.nvim"
  fi
}

install_common() {
  _download_and_install
  ln -sfn "$FEATURE_ROOT/conf" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
}

get_resources() {
  _get_installed_resource "$HOME/.config/nvim" "$HOME/.local/share/nvim"
}

update() {
  if command -v nvim &> /dev/null && [ "$(nvim -v | head -n 1 | awk '{print $NF}')" = $NEOVIM_VERSION ]; then
    echo "Neovim is up-to-date (version: $NEOVIM_VERSION). Skipping."
  else
    _download_and_install
    echo "Done! Neovim has been successfully updated to $NEOVIM_VERSION version."
  fi
}

main "$@"
