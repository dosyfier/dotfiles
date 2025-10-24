# Go related aliases

GO_HOME="$DOTFILES_TOOLS_DIR/go"

if [[ ":$PATH:" != *":$GO_HOME/bin:"* ]]; then
  export PATH="$GO_HOME/bin:$PATH"
fi


