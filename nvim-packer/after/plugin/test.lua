vim.g['test#strategy'] = 'vimux'
vim.g['test#python#pytest#executable'] = 'pytest'

vim.keymap.set('n', '<leader>rt', vim.cmd.TestNearest, {})
vim.keymap.set('n', '<leader>rf', vim.cmd.TestFile, {})
