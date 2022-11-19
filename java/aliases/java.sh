# Java shell aliases

load_jenv() {
  # Add jenv to PATH when it's not already present
  if [ -d "$HOME/.jenv/bin" ] && [[ ":$PATH:" != *":$HOME/.jenv/bin:"* ]]; then
    PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init - zsh)"
  fi
}
