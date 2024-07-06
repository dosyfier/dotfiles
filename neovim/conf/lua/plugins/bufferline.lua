return {
  -- See buffers as tabs
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        -- FIXME: Doesn't seem to work despite its conformity to:
        -- :help bufferline-numbers
        numbers = function(opts)
          return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
        end,
        diagnostics = "nvim_lsp",
      },
    },
    config = function()
      require("bufferline").setup()
    end,
  },
}
