return {
  "navarasu/onedark.nvim",
  config = function()
    require("onedark").setup({
      transparent = true,
      diagnostics = {
        background = false,
      },
    })
    vim.cmd.colorscheme("onedark")
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  end
}
