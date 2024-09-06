return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
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
        --preview = {
          --hide_on_startup = true -- hide previewer when picker starts
        --},
        sorting_strategy = "descending",
        layout_strategy = "vertical",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            prompt_position = "bottom",
            width = function(_, max_columns, _)
              return math.min(max_columns, 80)
            end,
            height = function(_, _, max_lines)
              return math.min(max_lines, 15)
            end,
            preview_cutoff = 100,
          },
          width = 0.87,
          height = 0.20,
        },
      },
    })

    -- https://github.com/navarasu/onedark.nvim/blob/master/lua/onedark/palette.lua
    --local colors = require("onedark.palette")["dark"]
    --local background = "#1d1f21"
    --local telescope_background = colors.bg1
    --local selection_background = "#3d4347"
    --vim.api.nvim_set_hl(0, "TelescopePromptNormal", {fg = colors.white, bg = telescope_background})
    --vim.api.nvim_set_hl(0, "TelescopePromptBorder", {fg = telescope_background, bg = telescope_background})
    --vim.api.nvim_set_hl(0, "TelescopePromptTitle", {bg = colors.bg_blue})

    --vim.api.nvim_set_hl(0, "TelescopeResultsTitle", {fg = background, bg = background})
    --vim.api.nvim_set_hl(0, "TelescopeNormal", {bg = background})
    --vim.api.nvim_set_hl(0, "TelescopeResultsBorder", {fg = background, bg = background})

    --vim.api.nvim_set_hl(0, "TelescopeSelection", {bg = selection_background})
  end,
}
