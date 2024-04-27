return {
  {
    "VonHeikemen/lsp-zero.nvim",
    event = {'BufReadPre', 'BufNewFile'},
    cmd = 'Mason',
    branch = "v2.x",
    dependencies = {
      -- LSP Support
      {"neovim/nvim-lspconfig"},
      {"williamboman/mason.nvim"},
      {"williamboman/mason-lspconfig.nvim"},

      -- Autocompletion
      {"hrsh7th/nvim-cmp"},
      {"hrsh7th/cmp-nvim-lsp"},
      {"L3MON4D3/LuaSnip"},
    },
    config = function()
      local lsp = require("lsp-zero").preset("recommended")

      lsp.set_preferences({
        suggest_lsp_servers = false,
        sign_icons = {
          error = "E",
          warn = "W",
          hint = "H",
          info = "I"
        }
      })

      lsp.on_attach(function(client, bufnr)
        require("plugins.lsp.callbacks")
      end)

      require("lspconfig").pylsp.setup({
        settings = {
          pylsp = {
            configurationSources = {"pylint", "flake8"},
            plugins = {
              pylint = {enabled = true},
              flake8 = {enabled = true},
              isort = {enabled = true},
              pycodestyle = {enabled = false},
              mccabe = {enabled = false},
              pyflakes = {enabled = true},
            }
          }
        }
      })

      require("lspconfig").gopls.setup({
        cmd = {"gopls"},
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
            },
          },
        },
      })

      lsp.setup()
      vim.diagnostic.config({virtual_text = true})
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
  },
}
