return {
  {
    "apaslak/factory_finder.nvim",
    version = "v1.2.0", -- Use for stability; omit to use `main` branch for the latest features
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("factory_finder").setup({
        open_in_new_tab = true
      })
    end,
    event = 'VeryLazy',
    keys = {
      { "<leader>fd", ":SmartGoToDefinition<CR>", desc = "[F]ind [d]efinition" },
    }
  },

  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },

  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    config = function()
      require("fidget").setup({})
    end,
  },

  --{"dstein64/vim-startuptime"},

  -- better status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "catppuccin-macchiato",
          component_separators = '',
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            { "diagnostics", sources = { "nvim_lsp" } },
            "encoding",
            "fileformat",
            "filetype"
          },
          lualine_y = { "progress" },
          lualine_z = { "location" }
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
      vim.g["test#ruby#rspec#executable"] = "bundle exec rspec"

      vim.keymap.set("n", "<leader>rt", function() vim.cmd.TestNearest() end, { desc = "[Test] [R]un [T]est" })
      vim.keymap.set("n", "<leader>rf", function() vim.cmd.TestFile() end, { desc = "[Test] [R]un [F]ile" })
    end,
  },

  ---- Allow vim to send commands to tmux
  { "preservim/vimux", event = "VeryLazy" },

  -- window zoom
  {
    "anuvyklack/windows.nvim",
    event = "VeryLazy",
    dependencies = "anuvyklack/middleclass",
    config = function()
      require('windows').setup()

      vim.keymap.set("n", "<leader>zw", function()
        vim.cmd.WindowsMaximize()
      end, { desc = "[Z]oom into [W]indow" })
    end
  },

  -- easily add/delete/change "surroundings"
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({})
    end
  },

  -- multiple cursors
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },

  -- git integration
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gs", function() vim.cmd('Git') end, { desc = "[Git] [G]it [S]tatus" })
      vim.keymap.set("n", "<leader>gd", function() vim.cmd('Gvdiffsplit') end, { desc = "[Git] [G]it [D]iff" })
      vim.keymap.set("n", "<leader>gb", function() vim.cmd('Git blame') end, { desc = "[Git] [G]it [B]lame" })
    end
  },

  -- repeat motions
  { "tpope/vim-repeat" },

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

      vim.keymap.set("n", "<C-f>f", ":CtrlSF ", { desc = "Launch CtrlSF" })
    end,
  },

  -- better quickfix?
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    event = "VeryLazy"
  },

  -- syntax highlighting for helm
  -- cant lazy load or ft load
  { 'towolf/vim-helm' },

  -- syntax highlighting for mustache/handlebars
  {
    "mustache/vim-mustache-handlebars",
    ft = { "yml", "mustache" }
  },

  -- UML diagrams
  { "scrooloose/vim-slumlord", ft = "plantuml", event = "VeryLazy" },
  { "aklt/plantuml-syntax",    ft = "plantuml", event = "VeryLazy" },

  -- smarter intend settings
  { 'tpope/vim-sleuth' },

  {
    'wassimk/gh-navigator.nvim',
    version = "v0.1.3",
    event = "VeryLazy",
    config = true,
    keys = {
      { "<leader>or", ":GH pr<CR>", desc = "[O]pen P[R]" },
    }
  },
}
