-- Displays the syntax highlight group (and link, if there is one)
-- of the word at the current cursor position
-- Cf. https://stackoverflow.com/a/37040415/4601482
function SynGroup()
  vim.cmd([[
    let syn_group = synID(line('.'), col('.'), 1)
    echo synIDattr(syn_group, 'name') . ' -> ' . synIDattr(synIDtrans(syn_group), 'name')
  ]])
end
vim.keymap.set('n', '<Leader>y', SynGroup, { desc = 'Display syntax highlight group' })
