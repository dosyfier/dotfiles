#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

RUBY_VERSION="3.4.7"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
  if ! command -v rustc &>/dev/null; then
    echo rust
  fi
}

install_common() {
  _install_build_dependencies
  _install_ruby
  _install_gems
}

_install_build_dependencies() {
  # Ref: https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
  case $(get_distro_type) in
    ubuntu)
      install_packages curl build-essential autoconf \
        libssl-dev libyaml-dev zlib1g-dev libffi-dev libgdbm-dev;;
    rhel)
      install_packages curl make autoconf gcc patch bzip2 \
        openssl-devel libyaml-devel libffi-devel readline zlib-devel gdbm \
        ncurses-devel tar perl-FindBin;;
    *)
      echo "ERROR: Unsupported OS distrib for Ruby compilation." >&2
      return 1;;
  esac
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

get_resources() {
  _get_installed_resource "$HOME/.rubocop.yml"
}

update() {
  git -C "$HOME"/.rbenv pull
}

main "$@"
