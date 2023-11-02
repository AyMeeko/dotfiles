return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  tag = "0.1.2",
  dependencies = {
    {"nvim-lua/plenary.nvim"},
    {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
    {"benfowler/telescope-luasnip.nvim"},
  },
  config = function()
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("luasnip")

    local actions = require("telescope.actions")
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {["<C-d>"] = "delete_buffer"},
          n = {["dd"] = "delete_buffer", ["q"] = actions.close},
          --i = { ["<esc>"] = actions.close }
        },
        preview = {
          hide_on_startup = true -- hide previewer when picker starts
        },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
      },
      extensions = {
        file_browser = {
          theme = "ivy",
        },
      },
    })
    --require("telescope").load_extension("file_browser")
  end,
}
