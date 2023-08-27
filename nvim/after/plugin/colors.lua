require('onedark').setup  {
  -- Main options --
  transparent = true,  -- Show/hide background

  -- Plugins Config --
  diagnostics = {
    background = false,    -- use background color for virtual text
  },
}

vim.opt.termguicolors = true
vim.opt.background = "dark"

function SetColor(color)
    color = color or "onedark"
    vim.cmd.colorscheme(color)
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    --vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { bg = "none" })
end

SetColor() -- run at startup

require 'colorizer'.setup()
