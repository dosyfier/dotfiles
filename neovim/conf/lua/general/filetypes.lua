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

-- Filetype settings related to "pearofducks/ansible-vim" plugin
vim.g.ansible_template_syntaxes = {
  ["*.yaml.j2"] = "yaml",
  ["*.yml.j2"] = "yaml",
}

-- vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
--   pattern = { "*.conf{,ig}.j2" },
--   callback = function()
--     local buf_lines = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), true)
--
--     -- skip comment lines
--     local lnr = 0
--     local current_line = buf_lines[lnr]
--     lnr = lnr + 1
--     while (string.match(current_line, "^#")) do
--       current_line = buf_lines[lnr]
--     end
--
--     -- look for Logstash keywords in the next 10 lines
--     for _=1,10 do
--       if (string.match(current_line, '^[ \t]*(input|filter|output) {')) then
--         vim.opt.filetype = "logstash.jinja2"
--         break
--       end
--       lnr = lnr + 1
--       current_line = buf_lines[lnr]
--     end
--   end
-- })

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = { "*.json.j2" },
  command = "set filetype=json.jinja2"
})
