-- Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
-- which is the default
vim.keymap.set('n', 'Y', 'y$')

-- Map <C-L> (redraw screen) to also turn off search highlighting until the
-- next search
vim.keymap.set('n', '<C-L>', ':nohl<CR><C-L>')

-- Press Ctrl-r after selecting some text in visual mode to template a
-- '%s' Vim command to substitute it.
vim.keymap.set('v', '<C-r>', '"hy:%s/<C-r>h/<C-r>h/gc<left><left><left>')

-- Shortcut to open the current file into firefox
vim.keymap.set('n', '<F12>f', ":exe ':silent !" ..
  "source ~/.dotfiles.env; " ..
  "source $DOTFILES_DIR/internal/aliases/distro.sh; " ..
  "if command -v wslpath > /dev/null; " ..
  "then firefox \"file:///$(wslpath -m \"%\")\"; " ..
  "else firefox \"file:///%\"; " ..
  "fi'<CR>")
