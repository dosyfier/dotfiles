# Ruby shell aliases

load_rb() {
  # Add rbenv to PATH when it's not already present
  if [ -d "$HOME/.rbenv/bin" ] && [[ ":$PATH:" != *":$HOME/.rbenv/bin:"* ]]; then
    PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init - zsh)"
  fi
}
