return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          telescope = {
            enabled = true,
             style = "nvchad"
          },
          vimwiki = true,
          indent_blankline = {
            enabled = true,
            scope_color = "", -- catppuccin color (eg. `lavender`) Default: text
            colored_indent_levels = false,
          },
          headlines = true,
          fidget = true,
        }
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },
  {
    "navarasu/onedark.nvim",
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

      require('colorizer').setup()
    end
  }
}
