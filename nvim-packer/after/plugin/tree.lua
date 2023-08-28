require("nvim-tree").setup({
  view = {
    width = 55,
  }
})

vim.keymap.set("n", "<leader>n", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>f<space>", vim.cmd.NvimTreeFindFile)

-- if nvim open without args, open Tree view
-- if nvim open with file, open Tree view, move it to the left-most tab, refocus opened file
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      vim.cmd('NvimTreeToggle')
      vim.cmd('wincmd l')
      vim.cmd('q')
      vim.cmd('bdelete 1')
    else
      vim.cmd('tabnew ~/.nvim_tree')
      vim.cmd('tabm 0')
      vim.cmd('NvimTreeToggle')
      vim.cmd('bdelete 3')
      vim.cmd('tabn')
    end
  end,
})
