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
      -- nice little symbols in the auto complete menu
      {"onsails/lspkind.nvim", event = "VeryLazy"},
    },
    config = function()
      local lsp = require("lsp-zero").preset("recommended")
      local luasnip = require("luasnip")

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
            --configurationSources = {"pylint", "flake8"},
            plugins = {
              pylint = {enabled = false},
              flake8 = {enabled = false},
              isort = {enabled = false},
              pycodestyle = {enabled = false},
              mccabe = {enabled = false},
              pyflakes = {enabled = false},
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

      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        --window = {
          --completion = cmp.config.window.bordered(),
          --documentation = cmp.config.window.bordered(),
        --},
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
          ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
          ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- scroll up preview
          ["<C-d>"] = cmp.mapping.scroll_docs(4), -- scroll down preview
          ["<C-Space>"] = cmp.mapping.complete({}), -- show completion suggestions
          ["<C-c>"] = cmp.mapping.abort(), -- close completion window
        }),
        -- sources for autocompletion
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- lsp
          { name = "buffer", max_item_count = 5 }, -- text within current buffer
          { name = "path", max_item_count = 3 }, -- file system paths
          { name = "luasnip", max_item_count = 3 }, -- snippets
        }),
        -- Enable pictogram icons for lsp/autocompletion
        formatting = {
          expandable_indicator = true,
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        experimental = {
          ghost_text = true,
        },
      })
    end,

  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
  },
}
