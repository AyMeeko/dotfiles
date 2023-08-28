vim.g.ctrlsf_position = 'bottom'
vim.g.ctrlsf_winsize = '25%'
vim.g.ctrlsf_case_sensitive = 'smart'
vim.g.ctrlsf_default_root = 'project'
vim.g.ctrlsf_ackprg = '/opt/homebrew/bin/rg'

vim.keymap.set("n", "<C-f>f", ":CtrlSF ")
