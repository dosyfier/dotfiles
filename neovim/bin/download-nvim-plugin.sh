#!/bin/bash

set -euo pipefail

if [ $# -lt 2 ] || [ $# -gt 3 ] || [[ "$*" =~ (-h|--help|-?) ]]; then
  cat <<-EOUSAGE

Usage: $(basename "$0") <PLUGIN_URL> <DOWNLOAD_DIR> [<PLUGIN_BRANCH>]"

  Downloads a Neovim plugin through an Artifactory VCS proxy configured via the following environment variable:
    GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN

  This environment variable is expected to include a <FUNCTION> placeholder, to be automatically substituted
  by this script with the name of the desired function in VCS API.

EOUSAGE
  exit 1
fi

if [ -z "$GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN" ]; then
  echo "Environment variable GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN is not set. Aborting." >&2
  exit 1
fi

PLUGIN_URL="$1"
DOWNLOAD_DIR="$2"
PLUGIN_BRANCH="${3:-}"

PLUGIN_URL_PATH="${PLUGIN_URL#https://github.com/}"
PLUGIN_URL_PATH="${PLUGIN_URL_PATH%.git}"

if [ -z "${PLUGIN_BRANCH:-}" ]; then
  PLUGIN_BRANCH="$(curl -sSfL --netrc \
      "${GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN//<FUNCTION>/branches}/$PLUGIN_URL_PATH" | \
      jq -r '.[].name' | grep -E '(master|main)' | head -n 1)"
fi
if [ -z "${PLUGIN_BRANCH:-}" ]; then
  echo "No default branch found for Neovim plugin $PLUGIN_URL. Aborting." >&2
  exit 2
fi

echo "Installing $PLUGIN_URL_PATH plugin (branch $PLUGIN_BRANCH) into $DOWNLOAD_DIR..."
mkdir -p "$DOWNLOAD_DIR"
curl -sSfL --netrc \
  "${GITHUB_ARTIFACTORY_VCS_PROXY_URL_PATTERN//<FUNCTION>/downloadBranch}/$PLUGIN_URL_PATH/$PLUGIN_BRANCH?ext=tar.gz" | \
  tar -xz --strip-components=1 -C "$DOWNLOAD_DIR"

# Special case for Mason plugin: we may need to adapt Pypi endpoint
if [ "$PLUGIN_URL_PATH" = "mason-org/mason.nvim" ] && [ -v GITHUB_ARTIFACTORY_PYPI_PROXY_URL ]; then
  echo "Fixing Pypi endpoint for Mason plugin..."
  sed -i "s|https://pypi.org|$GITHUB_ARTIFACTORY_PYPI_PROXY_URL|" \
    "$DOWNLOAD_DIR/lua/mason/providers/client/pypi.lua"
fi

echo "Configuring dummy git repository for $PLUGIN_URL_PATH plugin..."
git init -b "$PLUGIN_BRANCH" "$DOWNLOAD_DIR"
git -C "$DOWNLOAD_DIR" add -A
git -C "$DOWNLOAD_DIR" commit -m "Single commit"
git -C "$DOWNLOAD_DIR" remote add origin "$PLUGIN_URL"

echo "Done! $PLUGIN_URL_PATH plugin has been successfully installed."
