return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
    dependencies = {
      { "folke/lazydev.nvim",                       ft = "lua" },
      { "williamboman/mason.nvim",                  event = "VeryLazy" },
      { "williamboman/mason-lspconfig.nvim",        event = "VeryLazy" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      -- completion
      { "hrsh7th/cmp-nvim-lsp",                     event = "VeryLazy" },
      { "hrsh7th/nvim-cmp",                         event = "VeryLazy" },
      "hrsh7th/cmp-nvim-lsp-signature-help",
      -- snippets
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      -- pretty things
      "onsails/lspkind.nvim",
      "brenoprata10/nvim-highlight-colors",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Set border for LSPInfo window
      require('lspconfig.ui.windows').default_options = { border = "rounded" }

      local servers = {
        eslint = {
          cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=12288" },
        },
        graphql = {
          filetypes = { 'graphql' },
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, {
              '.git',
              '.graphqlrc',
              '.graphqlrc.json',
              '.graphqlrc.js',
              '.graphqlrc.yaml',
              '.graphqlrc.yml',
              'graphql.config.json',
              'graphql.config.js',
            }))
          end
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        marksman = {},
        rubocop = {
          manual_install = true,
          cmd = { "bundle", "exec", "rubocop", "--lsp", "--no-server" },
          filetypes = { "ruby" },
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, {
              "Gemfile",
              ".git",
            }))
          end
        },
        sorbet = {
          manual_install = true,
          cmd = { "bundle", "exec", "srb", "tc", "--lsp" },
          filetypes = { "ruby" },
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, {
              "Gemfile",
              ".git",
            }))
          end
        },
      }

      local formatters = {
        prettierd = {},
      }

      local mason_tools_to_install = vim.tbl_keys(vim.tbl_deep_extend("force", {}, servers, formatters))

      local ensure_installed = vim.tbl_filter(function(key)
        local t = servers[key]
        if type(t) == "table" then
          return not t.manual_install
        else
          return t
        end
      end, mason_tools_to_install)

      require("mason-tool-installer").setup({
        auto_update = true,
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 12,
        ensure_installed = ensure_installed,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      for name, config in pairs(servers) do
        vim.lsp.config(name, {
          cmd = config.cmd,
          capabilities = capabilities,
          filetypes = config.filetypes,
          settings = config.settings,
          root_dir = config.root_dir,
        })
        if config.autostart == false then
          -- Don't auto-enable servers with autostart = false
        else
          vim.lsp.enable(name)
        end
      end

      -- Executes the callback function every time a
      -- language server is attached to a buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        desc = 'LSP actions',
        callback = function(event)
          local opts = function(desc)
            return { buffer = event.buf, desc = desc }
          end

          vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts('[LSP] Next Diagnostic'))
          vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts('[LSP] Previous Diagnostic'))
          vim.keymap.set('n', '<leader>vd', '<cmd>lua vim.diagnostic.open_float({border = "rounded"})<cr>',
            opts('[LSP] [V]iew [D]iagnostic'))
          vim.keymap.set('n', '<leader>rs', '<cmd>lua vim.lsp.buf.rename()<cr>', opts('[LSP] [R]ename [S]ymbol'))
          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover({border = "rounded"})<cr>', opts('[LSP] Hover'))
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts('[LSP] Code Action'))
          -- vim.keymap.set('n', 'gd', '<cmd>tab split | lua vim.lsp.buf.definition()<cr><cmd>norm zz<cr>', opts('[LSP] [g]o to [d]efinition'))
          vim.keymap.set('n', 'gd', '<cmd>lua require("plugins.lsp.go_to").definition()<cr><cmd>norm zz<cr>',
            opts('[LSP] [g]o to [d]efinition'))
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr><cmd>norm zz<cr>',
            opts('[LSP] [g]o to [d]eclaration'))
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr><cmd>norm zz<cr>',
            opts('[LSP] [g]o to [i]mplementation'))
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr><cmd>norm zz<cr>',
            opts('[LSP] [g]o to ... type definition'))
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts('[LSP] [g]o to [r]eferences'))
          vim.keymap.set({ 'n', 'x' }, 'gf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>',
            opts('[LSP] [g]o [f]ormat file'))
        end,
      })

      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup()

      local cmp = require('cmp')
      local format_item_with_lspkind = require("lspkind").cmp_format({
        mode = "symbol_text",
        maxwidth = 50,
        ellipsis_char = "...",
        menu = {
          nvim_lsp = "[LSP]",
          buffer = "[Buffer]",
          path = "[Path]",
          luasnip = "[Snippet]",
          nvim_lsp_signature_help = "[Signature]",
        },
      })

      cmp.setup({
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },                    -- lsp
          { name = "buffer",  max_item_count = 5 }, -- text within current buffer
          { name = "copilot", group_index = 2 },    -- GitHub Copilot
          { name = "path",    max_item_count = 3 }, -- file system paths
          { name = "luasnip", max_item_count = 3 }, -- snippets
          -- { name = "nvim-lsp-signature-help" },
        }),
        -- Enable pictogram icons for lsp/autocompletion
        formatting = {
          expandable_indicator = true,
          format = function(entry, item)
            local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
            item = format_item_with_lspkind(entry, item)

            if color_item.abbr_hl_group then
              item.kind_hl_group = color_item.abbr_hl_group
              item.kind = color_item.abbr
            end

            return item
          end,
        },
        experimental = {
          ghost_text = true,
        },
      })
      vim.diagnostic.config({ virtual_text = true })
    end
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig"
    },
    opts = {
      settings = {
        tsserver_max_memory = 8192
      }
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        notify_on_error = false,
        default_format_opts = {
          async = true,
          timeout_ms = 500,
          lsp_format = "fallback",
        },
        -- format_after_save = {
        --   async = true,
        --   timeout_ms = 500,
        --   lsp_format = "fallback",
        -- },
        formatters_by_ft = {
          javascript = { "prettier", "prettierd" },
          typescript = { "prettier", "prettierd" },
          typescriptreact = { "prettier", "prettierd" },
          svelte = { "prettier", "prettierd" },
          lua = { "stylua" },
        },
        format_after_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { async = true, timeout_ms = 500, lsp_format = "fallback" }
        end,
      })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
  },
}
