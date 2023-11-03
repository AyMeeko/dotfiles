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
    local dark = {
      black = "#181a1f",
      bg0 = "#282c34",
      bg1 = "#31353f",
      bg2 = "#393f4a",
      bg3 = "#3b3f4c",
      bg_d = "#21252b",
      bg_blue = "#73b8f1",
      bg_yellow = "#ebd09c",
      fg = "#abb2bf",
      purple = "#c678dd",
      green = "#98c379",
      orange = "#d19a66",
      blue = "#61afef",
      yellow = "#e5c07b",
      cyan = "#56b6c2",
      red = "#e86671",
      grey = "#5c6370",
      light_grey = "#848b98",
      dark_cyan = "#2b6f77",
      dark_red = "#993939",
      dark_yellow = "#93691d",
      dark_purple = "#8a3fa0",
      diff_add = "#31392b",
      diff_delete = "#382b2c",
      diff_change = "#1c3448",
      diff_text = "#2c5372",
    }
    -- https://github.com/navarasu/onedark.nvim/blob/master/lua/onedark/palette.lua
    local colors = require("onedark.palette")["dark"]
    local background = "#1d1f21"
    local telescope_background = colors.bg1
    local selection_background = "#3d4347"
    --vim.api.nvim_set_hl(0, "TelescopeBorder", {fg = colors.yellow, bg = colors.yellow})

    --vim.api.nvim_set_hl(0, "TelescopePreviewTitle", {fg = colors.black, bg = colors.green})

    --vim.api.nvim_set_hl(0, "TelescopePromptPrefix", {fg = colors.red, bg = colors.black})
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", {fg = colors.white, bg = telescope_background})
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", {fg = telescope_background, bg = telescope_background})
    vim.api.nvim_set_hl(0, "TelescopePromptTitle", {bg = colors.bg_blue})

    vim.api.nvim_set_hl(0, "TelescopeResultsTitle", {fg = background, bg = background})
    vim.api.nvim_set_hl(0, "TelescopeNormal", {bg = background})
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", {fg = background, bg = background})

    vim.api.nvim_set_hl(0, "TelescopeSelection", {bg = selection_background})

    --local TelescopeColor = {
      --TelescopeMatching = { fg = colors.flamingo },
      --TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },
      --TelescopePromptPrefix = { bg = colors.surface0 },
      --TelescopePromptNormal = { bg = colors.surface0 },
      --TelescopeResultsNormal = { bg = colors.mantle },
      --TelescopePreviewNormal = { bg = colors.mantle },
      --TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
      --TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
      --TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
      --TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
      --TelescopeResultsTitle = { fg = colors.mantle },
      --TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
    --}
  end,
}
