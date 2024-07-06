# NeoVim related aliases

NEOVIM_HOME=/opt/nvim-linux64

if [[ ":$PATH:" != *":$NEOVIM_HOME/bin:"* ]]; then
  export PATH="$NEOVIM_HOME/bin:$PATH"
fi
