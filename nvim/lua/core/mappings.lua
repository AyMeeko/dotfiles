vim.g.mapleader = ","
vim.keymap.set("n", "<leader>n", vim.cmd.Ex)

-- Ctrl h and l to change buffers
vim.keymap.set("n", "<C-l>", vim.cmd.tabn)
vim.keymap.set("n", "<C-h>", vim.cmd.tabp)

-- Makes cursor not jump 'over' a line if it's wrapped to.a second line
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Clear last search
vim.keymap.set("n", "<leader>/", vim.cmd.nohlsearch)

-- make command line work with emacs style editing
vim.keymap.set("c", "<C-a>", "<Home>")
vim.keymap.set("c", "<C-e>", "<End>")
vim.keymap.set("c", "<M-f>", "<S-Right>")
vim.keymap.set("c", "<M-b>", "<S-Left>")

-- Allow variations of wq and qa
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
vim.api.nvim_create_user_command("Q", "q", {})

-- Format JSON
vim.api.nvim_create_user_command("FormatJson", "%!jq .", {})
vim.keymap.set("n", "<leader>fj", vim.cmd.FormatJson)

-- Map za to <space> for folding/unfolding
vim.keymap.set("n", "<space>", "za")

-- Switch to previous buffer
vim.keymap.set("n", "<space><tab>", vim.cmd.bprev)
