local group = vim.api.nvim_create_augroup('user_cmds', { clear = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = group,
  pattern = "*",
})

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
  group = group,
})

-- Allow variations of wq and qa
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
vim.api.nvim_create_user_command("Q", "q", {})

-- Format JSON*
vim.api.nvim_create_user_command("FormatJson", "%!jq .", {})

-- nvim 0.12 ships a builtin :lsp command, which makes nvim-lspconfig skip
-- defining its legacy commands (LspInfo etc). Recreate the old alias.
vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to :checkhealth vim.lsp" })

-- List of commands I rarely use and don't want to give a hotkey but also don't want to forget
-- lsp.lua -> conform.nvim
-- FormatEnable
-- FormatDisable
-- FormatJson (this file)
