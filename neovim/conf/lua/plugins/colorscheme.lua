return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      -- use the night style
      style = "night",
      -- add bold styling
      styles = {
        keywords = { bold = true },
        functions = { bold = true },
      },
      -- Set up base colors
      on_colors = function(colors)
        colors.warmblack = "#262626"
        colors.warmwhite = "#b2b2b2"
        colors.warmgray = "#808080"
        colors.warmgreen = "#afd787"
        colors.gold = "#d7d787"
        colors.seagreen = "#2ab6cf"
        colors.lightgreen = "#a0faa0"
        colors.lightgold = "#fcf5ae"
        colors.lightyellow = "#c9c9a4"
        colors.salmonpink = "#d7afd7"
        colors.orange = "#d7af87"
        colors.rust = "#d78787"
        colors.darkblue = "#000875"
        colors.darkgreen = "#0c8501"
      end,
      -- Set up color-mapping & style of hilights
      on_highlights = function(hl, c)
        -- Main
        hl.Normal = { fg = c.warmwhite, bg = c.warmblack }
        hl.Comment.fg = c.warmgray

        -- Constant
        hl.Constant = {
          fg = c.gold,
          style = { bold = true, italic = true }
        }
        hl.String = { fg = c.lightyellow }
        hl.Character = {
          fg = c.lightyellow,
          style = { bold = true }
        }
        hl.Boolean = {
          fg = c.lightyellow,
          style = { bold = true, italic = true }
        }
        hl.Number = {
          fg = c.orange,
          style = { bold = true, italic = true }
        }
        hl.Float = { link = "Number" }

        -- Variable names
        hl.Identifier = { fg = c.salmonpink, style = { bold = true } }
        hl.Function = { fg = c.magenta, style = { bold = true } }

        -- Statements
        hl.Statement = { fg = c.cyan, style = { bold = true } }
        hl.Conditional = { link = "Statement" }
        hl.Repeat = { link = "Statement" }
        hl.Label = { link = "Statement" }
        hl.Operator = { link = "Statement" }
        hl.Keyword = { link = "Statement" }
        hl.Exception = { link = "Statement" }

        -- Preprocessor
        hl.PreProc = { fg = c.warmgreen, style = { bold = true } }
        hl.Include = { link = "PreProc" }
        hl.Define = { link = "PreProc" }
        hl.Macro = { link = "PreProc" }
        hl.PreCondit = { link = "PreProc" }

        -- Type
        hl.Type = { fg = c.seagreen, style = { bold=true } }
        hl.StorageClass = { link = "Type" }
        hl.Structure = { link = "Type" }
        hl.Typedef = { link = "Type" }

        -- Special
        hl.Special.fg = c.rust
        hl.SpecialComment = { style = { bold = true } }

        -- Diff mode
        hl.DiffAdd = { bg = "#afd75f", fg = "#000000" }
        hl.DiffChange = { bg = "#ffafaf", fg = "#000000" }
        hl.DiffDelete = { bg = "#ff87af", fg = "#000000" }
        hl.DiffText = { bg = "#b2b2b2", fg = "#000000", style = { bold = true } }

        -- Treesitter
        hl["@keyword.import"] = { fg = c.lightgreen, style = { bold = true } }

        -- LSP
        hl["@lsp.type.keyword"] = { fg = c.green, style = { bold = true } }

        -- Make
        hl.makeCommands = { fg = c.lightgold }

        -- Jinja
        hl.jinjaVariable = { link = "Constant" }

        -- Ansible
        hl.ansible_normal_keywords = { link = "@lsp.type.keyword" }

        -- YAML
        hl.yamlFlowString = { fg = c.lightgreen }

        -- Folke / Flash
        -- hl.FlashLabel  = { bg = c.magenta, fg = c.black }
        hl.FlashLabel  = { bg = c.cyan, fg = c.black }
        hl.FlashCursor = { bg = c.black, fg = c.lightgold }
      end,
    }
  }
}
