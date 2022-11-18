# Python shell aliases

load_py() {
  # Add pyenv to PATH when it's not already present
  export PYENV_ROOT="$HOME/.pyenv"
  if [ -d "$PYENV_ROOT/bin" ] && [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
    PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  fi
}
