-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Add lazy.nvim and expected plugins
require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    -- import/override with your plugins
    { import = "plugins" },
  },
})

-- Configure LazyVim and plugins installed by it

-- Override LazyVim auto formatting
vim.g.autoformat = false

-- Necessary for the xmledit plugin
-- (otherwise, the default '>' key mapping isn't working)
vim.g.xml_tag_completion_map = "<C-e>"

-- Correct syntax highlight for Jinja2 template files
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.jinja", "*.j2"},
  callback = function()
    vim.opt.filetype = "jinja2"
  end,
})
