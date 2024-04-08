return {
  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    dependencies = {"L3MON4D3/LuaSnip"},
    config = function ()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        sources = cmp.config.sources(
        {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
        {
          { name = 'buffer' },
        }),
        mapping = {
          ["<C-y>"] = cmp.mapping.confirm { select = true },
          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif luasnip.has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
      })

    end,
  },
  {"saadparwaiz1/cmp_luasnip", event = "VeryLazy"},
  {
    "L3MON4D3/LuaSnip",
    event = "VeryLazy",
    version = "2.*",
    build = "make install_jsregexp",
    dependencies = {"rafamadriz/friendly-snippets"},
    config = function()
      local luasnip = require("luasnip")
      luasnip.config.set_config({
        history = true
      })
      local snip = luasnip.snippet
      local node = luasnip.snippet_node
      local text = luasnip.text_node
      local insert = luasnip.insert_node
      local func = luasnip.function_node
      local choice = luasnip.choice_node
      local dynamicn = luasnip.dynamic_node

      -- https://sbulav.github.io/vim/neovim-setting-up-luasnip/
      luasnip.add_snippets(nil, {
        vimwiki = {
          snip({
            trig = "meta",
            namr = "Metadata",
            dscr = "Yaml metadata format for markdown"
          },
          {
            text({"---", "tags: :"}), insert(1, "tag"),
            text({":", "---", ""}),
            insert(0)
          }),
        },
      })
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").load({paths = "~/src/personal/private-snippets"})
    end,
  }
}
