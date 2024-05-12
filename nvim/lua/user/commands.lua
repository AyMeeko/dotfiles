local group = vim.api.nvim_create_augroup('user_cmds', {clear = true})

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
vim.api.nvim_create_autocmd({"BufWritePre"}, {
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
vim.keymap.set("n", "<leader>fj", vim.cmd.FormatJson)
