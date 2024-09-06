return {
  {
    "folke/tokyonight.nvim",
    event = "VeryLazy",
    opts = {},
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
          notify = false,
          nvimtree = true,
          telescope = {
            enabled = true,
            style = "nvchad"
          },
          treesitter = true,
          vimwiki = true,
        }
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  {
    "navarasu/onedark.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "norcalli/nvim-colorizer.lua",
        event = "VeryLazy"
      }
    },
    config = function()
      require("onedark").setup({
        transparent = true,
        diagnostics = {
          background = false,
        },
        --style = "dark",
      })
      --vim.cmd.colorscheme("onedark")
      --vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      --vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

      -- headlines.nvim
      --vim.api.nvim_set_hl(0, 'Headline1', {fg = '#cb7676', bg = '#402626', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline2', {fg = '#c99076', bg = '#66493c', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline3', {fg = '#80a665', bg = '#3d4f2f', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline4', {fg = '#4c9a91', bg = '#224541', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline5', {fg = '#6893bf', bg = '#2b3d4f', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline6', {fg = '#d3869b', bg = '#6b454f', italic = false})
      --vim.api.nvim_set_hl(0, 'CodeBlock', {bg = '#31353f'})

      require('colorizer').setup({
        filetypes = { "*", "!TelescopeResults" },
      })
    end
  }
}
