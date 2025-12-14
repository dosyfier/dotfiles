# Go related aliases

GO_HOME="$DOTFILES_LOCAL_DIR/standalone/go"

if [[ ":$PATH:" != *":$GO_HOME/bin:"* ]]; then
  export PATH="$GO_HOME/bin:$PATH"
fi


