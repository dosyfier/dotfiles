-- Displays the syntax highlight group (and link, if there is one)
-- of the word at the current cursor position
-- Cf. https://stackoverflow.com/a/37040415/4601482
vim.api.nvim_exec([[
function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfunc
]], false)
