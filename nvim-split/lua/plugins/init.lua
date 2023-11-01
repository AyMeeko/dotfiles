return {
   {"dstein64/vim-startuptime"},

   --{"norcalli/nvim-colorizer.lua"},

  -- better status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "onedark"
        },
        sections = {
          lualine_a = {"mode"},
          lualine_b = {"branch", "diff"},
          lualine_c = {{"filename", path=1}},
          lualine_x = {
            {"diagnostics", sources = {"nvim_lsp"}},
            "encoding",
            "fileformat",
            "filetype"
          },
          lualine_y = {"progress"},
          lualine_z = {"location"}
        }
      })
      vim.opt.showmode = false -- hide status bar so there aren't two
    end,
  },

  ---- Run pytest in tmux pane
  {
    "vim-test/vim-test",
    config = function()
      vim.g["test#strategy"] = "vimux"
      vim.g["test#python#pytest#executable"] = "pytest"
    end,
    lazy = true,
  },

  ---- Allow vim to send commands to tmux
  {"preservim/vimux", lazy = true},

  -- window zoom
  {"anuvyklack/windows.nvim", dependencies = "anuvyklack/middleclass", lazy = true},

  -- bubble text
  {"fedepujol/move.nvim"},

  -- easily add/delete/change "surroundings"
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },

  -- easy commenting/uncommenting
  {"scrooloose/nerdcommenter", lazy = true},

  -- multiple cursors
  {"mg979/vim-visual-multi", lazy = true},

  -- git integration
  {"tpope/vim-fugitive"},

  -- repeat motions
  {"tpope/vim-repeat"},

  -- grep
  {
    "dyng/ctrlsf.vim",
    config = function()
      vim.g.ctrlsf_position = "bottom"
      vim.g.ctrlsf_winsize = "25%"
      vim.g.ctrlsf_case_sensitive = "smart"
      vim.g.ctrlsf_default_root = "project"
      vim.g.ctrlsf_ackprg = "/opt/homebrew/bin/rg"
      vim.g.ctrlsf_search_mode = "async"
    end,
    lazy = true,
  },

  -- better python identation
  {"Vimjas/vim-python-pep8-indent"},

  -- open current file in GHE
  {"almo7aya/openingh.nvim", lazy = true},

   -- better quickfix?
   {'kevinhwang91/nvim-bqf', ft = 'qf'},

   {
     "lukas-reineke/indent-blankline.nvim",
     main = "ibl",
     opts = {},
     config = function()
       require("ibl").setup({enabled = false})
     end,
     lazy = true
   },

   -- syntax highlighting for helm
   {'towolf/vim-helm', lazy = true},

   -- syntax highlighting for mustache/handlebars
   {"mustache/vim-mustache-handlebars", lazy = true},
}
