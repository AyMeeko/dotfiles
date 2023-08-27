require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'onedark'
  },
  sections = {
    lualine_a = {"mode"},
    lualine_b = {"branch", "diff"},
    lualine_c = {"filename"},
    lualine_x = {
      {"diagnostics", sources = {"nvim_lsp"}},
      "encoding",
      "fileformat",
      "filetype"
    },
    lualine_y = {"progress"},
    lualine_z = {"location"}
  }
}

vim.o.showmode = false -- hide status bar so there aren't two
