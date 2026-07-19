#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

install_common() {
  # Install tmux itself (and "entr" command, which TPM depends on)
  install_packages tmux entr

  # Install its configuration file
  tmux_config_file="$HOME/.tmux.conf"
  if [ -e "$tmux_config_file" ]; then
    (>&2 echo "Tmux config file already exists ($tmux_config_file). Not overriding.")
  else
    echo "Installing tmux config file ($tmux_config_file)..."
    rm -f "$tmux_config_file" # in case the link is broken...
    ln -s "$FEATURE_ROOT"/conf/tmux.conf "$tmux_config_file"
  fi

  if [ -n "${GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN:-}" ]; then
    # Install TPM (Tmux Plugin Manager) and TMUX plugins, when relying on a corporate Artifactory proxy
    _install_tmux_plugins_through_artifactory_vcs_proxy
  else
    # Install TPM (Tmux Plugin Manager) only, in nominal mode
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
      git -C "$HOME/.tmux/plugins/tpm" pull
    else
      git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
  fi

  # Install Tmux Powerline config
  tmux_powerline_cfg_install_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-powerline"
  if ! [ -e "$tmux_powerline_cfg_install_dir" ]; then
    ln -s "$FEATURE_ROOT/conf/tmux-powerline" "$tmux_powerline_cfg_install_dir"
  fi
}

_install_tmux_plugins_through_artifactory_vcs_proxy() {
  tmux_plugins_dir="$HOME/.tmux/plugins"

  for tmux_plugin in $(grep -E '^set\s*-g\s*@plugin' "$FEATURE_ROOT/conf/tmux.conf" | \
    awk '{print $NF}' | tr -d \'\"); do

    echo "Checking stable git branch of TMUX plugin $tmux_plugin..."
    stable_branch="$(curl -sSfL --netrc \
      "${GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN//<FUNCTION>/branches}/$tmux_plugin" | \
      jq -r '.[].name' | grep -E '(master|main)' | head -n 1)"
    if [ -z "$stable_branch" ]; then
      echo "No default branch found for TMUX plugin $tmux_plugin. Aborting." >&2
      return 1
    fi

    echo "Download $stable_branch git branch for TMUX plugin $tmux_plugin..."
    tmux_plugin_dir="$tmux_plugins_dir/$(basename "$tmux_plugin")"
    mkdir -p "$tmux_plugin_dir"
    curl -sSfL --netrc \
      "${GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN//<FUNCTION>/downloadBranch}/$tmux_plugin/$stable_branch?ext=tar.gz" | \
      tar -xz --strip-components=1 -C "$tmux_plugin_dir"

    echo "TMUX plugin $tmux_plugin successfully installed."
  done 
}

get_resources() {
  _get_installed_resource "$HOME/.tmux.conf" "$HOME/.tmux-sessions.properties" \
    "$HOME/.tmux/plugins"
}

main "$@"
