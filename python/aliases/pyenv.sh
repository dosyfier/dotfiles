# Python shell aliases

DEFAULT_PYENV_VERSION=default

load_py() {
  # Add pyenv to PATH when it's not already present
  export PYENV_ROOT="$HOME/.pyenv"
  if [ -d "$PYENV_ROOT/bin" ] && [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
    PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    if ! [ -f "$PYENV_ROOT/version" ] && pyenv versions --bare | grep -qE "^$DEFAULT_PYENV_VERSION\$"; then
      pyenv activate "$DEFAULT_PYENV_VERSION"
    fi
  fi
}
