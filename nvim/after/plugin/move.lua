local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<C-j>', ':MoveLine(1)<CR>', opts)
vim.keymap.set('n', '<C-k>', ':MoveLine(-1)<CR>', opts)

vim.keymap.set('v', '<C-j>', ':MoveBlock(1)<CR>', opts)
vim.keymap.set('v', '<C-k>', ':MoveBlock(-1)<CR>', opts)
