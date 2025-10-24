return {
  -- Helper for git difftool / mergetool
  {
    "sindrets/diffview.nvim",
    opts = {
      hooks = {
        diff_buf_read = function(_)
          -- Change local options in diff buffers
          vim.opt_local.wrap = true
          vim.opt.wrap = true
        end
      }
    }
  },

  -- Git command bindings
  "tpope/vim-fugitive",

  -- XML files edition
  "sukima/xmledit",

  -- TreeSitter integration (incremental parser)
  "nvim-treesitter/nvim-treesitter",

  -- Great Tim Pope's plugins
  "tpope/vim-sleuth",
  "tpope/vim-surround",

  -- Logstash syntax highlight
  "robbles/logstash.vim",

  -- Ansible syntax highlight
  "pearofducks/ansible-vim",

  -- NGINX config files syntax highlighting
  "chr4/nginx.vim",

  -- Highlight and search for todo comments (TODO, FIXME, ...)
  "folke/todo-comments.nvim",

  -- Simple tools to help developers working YAML in Neovim
  {
    "cuducos/yaml.nvim",
    opts = {
      ft = { "yaml", "yaml.ansible" }
    }
  },

  -- Seamless navigation between tmux panes and vim splits 
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  }
}
