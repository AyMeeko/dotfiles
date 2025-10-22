return {
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function()
      require('colorizer').setup({})
      vim.keymap.set("n", "<leader>ct", ":ColorizerToggle<CR>", { desc = "[C]olorizer [t]oggle" })
    end
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        custom_highlights = function(colors)
          return {
            DiagnosticVirtualTextError = { bg = colors.none },
            DiagnosticVirtualTextWarn = { bg = colors.none },
            DiagnosticVirtualTextInfo = { bg = colors.none },
            DiagnosticVirtualTextHint = { bg = colors.none },
          }
        end,
        integrations = {
          cmp = true,
          fidget = true,
          gitsigns = true,
          headlines = true,
          mason = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
          notify = true,
          nvimtree = true,
          snacks = true,
          treesitter = true,
          vimwiki = true,
        }
      })
      vim.cmd.colorscheme "catppuccin"

      -- 'highlight' the current line number, but not the line itself
      local colors = require("catppuccin.palettes").get_palette("macchiato")
      vim.o.cursorline = true
      vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = colors.text })
      vim.api.nvim_set_hl(0, 'CursorLine', { bg = colors.base })
    end,
  },
}
