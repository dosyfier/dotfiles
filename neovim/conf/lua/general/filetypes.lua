vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {
    "*/playbooks/*.{yml,yaml}",
    "play-*.{yml,yaml}"
  },
  command = "set filetype=yaml.ansible"
})
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {
    ".gitlab-ci.{yml,yaml}",
    ".gitlab-ci/*.{yml,yaml}",
    "templates/gitlab-ci-*.{yml,yaml}"
  },
  command = "set filetype=yaml.gitlab"
})
