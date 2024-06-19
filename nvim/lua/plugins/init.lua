return {
  {
    "AyMeeko/stack-trace.nvim",
    event = "VeryLazy",
    version = "v0.2.0",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },

  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end,
  },

  --{"dstein64/vim-startuptime"},
  {"norcalli/nvim-colorizer.lua"},

  -- better status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          --theme = "onedark"
          theme = "catppuccin"
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
    event = "VeryLazy",
    config = function()
      vim.g["test#strategy"] = "vimux"
      vim.g["test#python#pytest#executable"] = "pytest"
    end,
  },

  ---- Allow vim to send commands to tmux
  {"preservim/vimux", event = "VeryLazy"},

  -- window zoom
  {
    "anuvyklack/windows.nvim",
    cmd = "WindowsMaximize",
    dependencies = "anuvyklack/middleclass",
  },

  -- bubble text
  --{"fedepujol/move.nvim"},

  -- easily add/delete/change "surroundings"
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({})
    end
  },

  -- easy commenting/uncommenting
  {"scrooloose/nerdcommenter"},

  -- multiple cursors
  {"mg979/vim-visual-multi"},

  -- git integration
  {"tpope/vim-fugitive"},

  -- repeat motions
  {"tpope/vim-repeat"},

  -- grep
  {
    "dyng/ctrlsf.vim",
    event = "VeryLazy",
    config = function()
      vim.g.ctrlsf_position = "bottom"
      vim.g.ctrlsf_winsize = "25%"
      vim.g.ctrlsf_case_sensitive = "smart"
      vim.g.ctrlsf_default_root = "project"
      vim.g.ctrlsf_ackprg = "/opt/homebrew/bin/rg"
      vim.g.ctrlsf_search_mode = "async"
    end,
  },

  -- better python identation
  {"Vimjas/vim-python-pep8-indent", event = "VeryLazy"},

  -- open current file in GHE
  {"almo7aya/openingh.nvim", event = "VeryLazy"},

   -- better quickfix?
   {"kevinhwang91/nvim-bqf", ft = "qf", event = "VeryLazy"},

   {
     "lukas-reineke/indent-blankline.nvim",
     event = "VeryLazy",
     main = "ibl",
     opts = {},
     config = function()
       require("ibl").setup({enabled = false})
     end,
   },

   -- syntax highlighting for helm
   {'towolf/vim-helm'},

   -- syntax highlighting for mustache/handlebars
   {"mustache/vim-mustache-handlebars"},

   -- UML diagrams
   {"scrooloose/vim-slumlord", ft = "plantuml", event = "VeryLazy"},
   {"aklt/plantuml-syntax", ft = "plantuml", event = "VeryLazy"},
}
