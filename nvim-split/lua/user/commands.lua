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

---- NVIM TREE ----
-- if nvim open without args, open Tree view
-- if nvim open with file, open Tree view, move it to the left-most tab, refocus opened file
--vim.api.nvim_create_autocmd("VimEnter", {
  --callback = function()
    --if vim.fn.argv(0) == "" then
      --vim.cmd("NvimTreeToggle")
      --vim.cmd("wincmd l")
      --vim.cmd("q")
      --vim.cmd("bdelete 1")
    --else
      --vim.cmd("tabnew ~/.nvim_tree")
      --vim.cmd("tabm 0")
      --vim.cmd("NvimTreeToggle")
      --vim.cmd("bdelete 3")
      --vim.cmd("tabn")
    --end
  --end,
--})

---- FIX TELESCOPE / TREESITTER FOLDING ISSUE ---
-- https://github.com/nvim-telescope/telescope.nvim/issues/699
--vim.api.nvim_create_autocmd({ "BufEnter", "BufNew", "BufWinEnter"  }, {
  --group = vim.api.nvim_create_augroup("ts_fold_workaround", { clear = true }),
  --command = "set foldexpr=nvim_treesitter#foldexpr()",
--})

