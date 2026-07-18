#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

OH_MY_ZSH_BRANCH=master
POWERLEVEL_10K_BRANCH=master

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
}

install_common() {
  install_packages zsh

  if [ -n "${GITHUB_ARTIFACTORY_VCS_URL_PATTERN:-}" ]; then
    _get_arks_through_artifactory_vcs_api
  else
    export RUNZSH=no                   # Prevents the installer from running zsh after installation
    export OVERWRITE_CONFIRMATION=no   # No confirmation asked before overwriting any existing .zshrc
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 "${GITHUB_PROXY_URL:-https://github.com}/romkatv/powerlevel10k.git" \
      "$(_get_powerlevel_10k_install_dir)"
  fi

  ln -vsfn "$FEATURE_ROOT"/conf/zshrc "$HOME"/.zshrc
  ln -vsfn "$FEATURE_ROOT"/conf/p10k.zsh "$HOME"/.p10k.zsh

  _install_or_update_gitstatus

  sed -ri 's/^(export DOTFILES_ENABLE_EXTERNAL_PROMPT=).*$/\1true/' "$DOTFILES_ENV_FILE"
}

get_resources() {
  _get_installed_resource "$HOME/.zshrc" \
    "$HOME/.oh-my-zsh" \
    "$HOME/.p10k.zsh"
}

update() {
  if [ -n "${GITHUB_ARTIFACTORY_VCS_URL_PATTERN:-}" ]; then
    reset_dir_with_parent "$HOME/.oh-my-zsh"
    _get_arks_through_artifactory_vcs_api
  else
    git -C "$HOME"/.oh-my-zsh pull
    git -C "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k pull
  fi
  _install_or_update_gitstatus
}

_get_powerlevel_10k_install_dir() {
  echo -n "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
}

_get_arks_through_artifactory_vcs_api() {
  vcs_url_prefix="${GITHUB_ARTIFACTORY_VCS_URL_PATTERN//<GIT_REF>/Branch}"
  curl -sSfL --netrc "$vcs_url_prefix/ohmyzsh/ohmyzsh/$OH_MY_ZSH_BRANCH?ext=tar.gz" | \
    tar -xz --strip-components=1 -C ~/.oh-my-zsh
  powerlevel_10k_install_dir="$(_get_powerlevel_10k_install_dir)"
  mkdir -p "$powerlevel_10k_install_dir"
  curl -sSfL --netrc "$vcs_url_prefix/romkatv/powerlevel10k/$POWERLEVEL_10K_BRANCH?ext=tar.gz" | \
    tar -xz --strip-components=1 -C "$powerlevel_10k_install_dir"
}

_install_or_update_gitstatus() {
  gitstatus_dir="$(_get_powerlevel_10k_install_dir)/gitstatus"

  gitstatus_install_info_file="$gitstatus_dir/install.info"
  echo "Parsing $gitstatus_install_info_file..."
  gitstatus_version="$(grep -Po 'uname_s_glob="linux".*uname_m_glob="x86_64".*version="\K[0-9\.v]+' \
    "$gitstatus_install_info_file")"
  if [ -z "$gitstatus_version" ]; then
    echo "No gitstatus_version found in $gitstatus_install_info_file. Aborting" >&2
    return 1
  else
    echo "Gitstatus version: $gitstatus_version"
  fi

  gitstatusd_ark_url="${GITHUB_PROXY_URL:-https://github.com}/romkatv/gitstatus/releases/download\
/${gitstatus_version}/gitstatusd-linux-x86_64.tar.gz"
  curl -sSfL --netrc "$gitstatusd_ark_url" | \
    tar -xz -C "$gitstatus_dir/usrbin/"
}

main "$@"
