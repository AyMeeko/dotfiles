require("core.mappings")
require("core.plugins")

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.hlsearch = true -- Set highlight on search
vim.o.ignorecase = true -- Case-insensitive searching 
vim.o.smartcase = true -- UNLESS \C or capital in search

-- Tabs
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

vim.wo.number = true -- Make line numbers default
vim.wo.relativenumber = true -- Relative line numbers
vim.o.mouse = 'a' -- Enable mouse mode
vim.o.undofile = true -- Save undo history

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set no compatible for Unimpaired?
vim.o.compatible = false

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

vim.opt.colorcolumn = "100"

-- Always show the gutter
vim.opt.signcolumn = "yes"

-- Folding :)
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldmethod = "expr"
vim.opt.foldlevel = 99

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.g.python3_host_prog = vim.fn.expand("$PYTHON3_HOST_PROG") -- Set python 3 provider

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- Show trailing whitespace as a dot
vim.opt.list = true
vim.opt.listchars = {trail = '.'}
