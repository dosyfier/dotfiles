#!/bin/bash

RUBY_VERSION="3.1.0"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
}

install_common() {
  _install_build_dependencies
  _install_ruby
  _install_gems
}

_install_build_dependencies() {
  install_packages curl libssl-dev libreadline-dev zlib1g-dev \
    autoconf bison build-essential libyaml-dev libreadline-dev \
    libncurses5-dev libffi-dev libgdbm-dev
}

_install_ruby() {
  curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
  eval "$("$HOME/.rbenv/bin/rbenv" init - bash)"
  if ! [ -d "$HOME/.rbenv/versions/$RUBY_VERSION" ]; then
    "$HOME/.rbenv/bin/rbenv" install "$RUBY_VERSION"
  fi
  "$HOME/.rbenv/bin/rbenv" global "$RUBY_VERSION"
}

_install_gems() {
  gem install \
    solargraph \
    chef \
    knife \
    rspec \
    rubocop \
    rake \
    rdoc \
    pry

  # Deploy Rubocop config file
  [ -e "$HOME"/.rubocop.yml ] && rm -vf "$HOME"/.rubocop.yml
  ln -vs "$FEATURE_ROOT"/conf/rubocop.yml "$HOME"/.rubocop.yml
}

main "$@"
