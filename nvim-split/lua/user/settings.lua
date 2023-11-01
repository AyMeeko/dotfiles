vim.opt.hlsearch = true -- Set highlight on search
vim.opt.ignorecase = true -- Case-insensitive searching
vim.opt.smartcase = true -- UNLESS \C or capital in search

-- Tabs
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

vim.wo.number = true -- Make line numbers default
vim.wo.relativenumber = true -- Relative line numbers again, I guess
vim.opt.mouse = 'a' -- Enable mouse mode
vim.opt.undofile = true -- Save undo history

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Set no compatible for Unimpaired?
vim.opt.compatible = false

-- Set completeopt to have a better completion experience
vim.opt.completeopt = "menuone,noselect"

vim.opt.colorcolumn = "100"

-- Always show the gutter
vim.opt.signcolumn = "yes"

-- Folding :)
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldmethod = "expr"
vim.opt.foldlevel = 99

--vim.g.python3_host_prog = vim.fn.expand("$PYTHON3_HOST_PROG") -- Set python 3 provider

-- Show trailing whitespace as a dot
vim.opt.list = true
vim.opt.listchars = {trail = "."}

vim.opt.termguicolors = true
vim.opt.background = "dark"
