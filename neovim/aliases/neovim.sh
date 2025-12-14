# NeoVim related aliases
# vim: set ft=bash

NEOVIM_HOME="$DOTFILES_TOOLS_DIR/nvim-linux-x86_64"

if [[ ":$PATH:" != *":$NEOVIM_HOME/bin:"* ]]; then
  export PATH="$NEOVIM_HOME/bin:$PATH"
fi

for vi_alias in vi vim; do
  if ! [ "$(readlink -f "$(which "$vi_alias" 2>/dev/null)")" = "$(readlink -f "$(which nvim)")" ]; then
    # shellcheck disable=SC2139 # Expansion is intended when defined
    alias "$vi_alias=nvim"
  fi
done

alias vig='vi +G +only'

# Use NeoVim as standard editor, e.g. for tools like `systemctl edit`
export EDITOR=nvim
