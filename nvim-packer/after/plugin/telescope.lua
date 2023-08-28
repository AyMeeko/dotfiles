require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
--vim.keymap.set('n', '<C-f>f', builtin.live_grep, {})
vim.keymap.set('n', '<leader>bl', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Close telescope window with one Esc hit
local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    mappings = {
      i = { ["<esc>"] = actions.close }
    },
    preview = {
      hide_on_startup = true -- hide previewer when picker starts
    }
  }
})
