#!/bin/bash

FEATURE_ROOT="$(readlink -f "$(dirname "$0")")"

# shellcheck source=../internal/install-base.sh
source "$(dirname "$0")/../internal/install-base.sh"

JAVA_VERSION="21.0.3+9"
MVN_VERSION="3.9.6"
# shellcheck disable=SC2016 # Expansion is intended later on (with an "eval echo <...>" cmd)
MVN_DOWNLOAD_URL_PATTERN='https://dlcdn.apache.org/maven/maven-${mvn_version_maj}\
/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz'

get_dependencies() {
  if ! command -v git &>/dev/null; then
    echo git
  fi
}

install_common() {
  if [ -d ~/.jenv ]; then
    echo "Jenv is already installed. Skipping."
  else
    echo "Installing Jenv..."
    git clone https://github.com/jenv/jenv.git ~/.jenv
  fi
  ln -sfn "$FEATURE_ROOT/bin/jenv-install.sh" ~/.jenv/bin/jenv-install

  if command -v java > /dev/null; then
    echo "Java is already installed. Skipping."
  else
    echo "Installing Java..."
    source "$FEATURE_ROOT/aliases/java.sh"
    jenv install "$JAVA_VERSION"
  fi

  if command -v mvn > /dev/null; then
    echo "Maven is already installed. Skipping."
  else
    echo "Installing Maven..."
    # shellcheck disable=SC2034 # this var is used when expanding Maven URL in following "eval" cmd
    mvn_version_maj="${MVN_VERSION%%.*}"
    sudo sh -c "curl -sSfL $(eval echo -n "$MVN_DOWNLOAD_URL_PATTERN") | tar -xz -C /opt"
    sudo ln -sfn "apache-maven-$MVN_VERSION" /opt/apache-maven
  fi
}

get_resources() {
  _get_installed_resource "$HOME/.jenv"
}

update() {
  git -C "$HOME"/.jenv pull
}

main "$@"
