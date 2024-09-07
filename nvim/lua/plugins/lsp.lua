return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {"williamboman/mason.nvim", event = "VeryLazy"},
    {"williamboman/mason-lspconfig.nvim", event = "VeryLazy"},
    {"hrsh7th/cmp-nvim-lsp", event = "VeryLazy"},
    {"hrsh7th/nvim-cmp", event = "VeryLazy"},
    {"L3MON4D3/LuaSnip", event = "VeryLazy"},
    {"j-hui/fidget.nvim", event = "VeryLazy"},
    {"onsails/lspkind.nvim", event = "VeryLazy"},
  },
  config = function()
    local cmp = require('cmp')
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities()
    )
    local lspkind = require("lspkind")

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "biome",
        "graphql",
        "helm_ls",
        "lua_ls",
        "marksman",
        "pylsp",
        "ruff",
        "terraformls",
        "ts_ls",
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities
          }
        end,

        ["graphql"] = function()
          local lspconfig = require('lspconfig')
          lspconfig.graphql.setup({
            filetypes = { 'graphql' },
            root_dir = lspconfig.util.root_pattern('.git', '.graphqlrc*', '.graphql.config.*', 'graphql.config.*')
          })
        end,

        ["biome"] = function()
          local lspconfig = require('lspconfig')
          lspconfig.biome.setup({
            filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
            root_dir = lspconfig.util.root_pattern('.git', 'tsconfig.json')
          })
        end,

        ["omnisharp"] = function()
          local lspconfig = require('lspconfig')
          lspconfig.omnisharp.setup({
            filetypes = { 'cs' },
            root_dir = lspconfig.util.root_pattern('.git', '*.sln', '*.csproj')
          })
        end,

        ["lua_ls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "Lua 5.1" },
                diagnostics = {
                  globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                }
              }
            }
          })
        end,
      }
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      completion = { completeopt = "menu,menuone,noinsert" },
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" }, -- lsp
        { name = "buffer", max_item_count = 5 }, -- text within current buffer
        { name = "path", max_item_count = 3 }, -- file system paths
        { name = "luasnip", max_item_count = 3 }, -- snippets
      }),
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

    vim.diagnostic.config({virtual_text = true})

    -- Executes the callback function every time a
    -- language server is attached to a buffer.
    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'LSP actions',
      callback = function(event)
        require("plugins.lsp.callbacks")
        local opts = {buffer = event.buf}

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
        vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
        vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
        vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
      end,
    })
  end
}
