return {
  {
    "vimwiki/vimwiki",
    event = "VeryLazy",
    init = function()
      vim.g.vimwiki_folding = ""
      vim.g.vimwiki_list = {
        {
          path = "~/notes",
          syntax = "markdown",
          ext = "md",
        },
        {
          path = "~/private_notes",
          syntax = "markdown",
          ext = "md",
        },
      }
      vim.g.vimwiki_ext2syntax = {
        ['.md'] = 'markdown',
        ['.markdown'] = 'markdown',
        ['.mdown'] = 'markdown'
      }
      vim.g.vimwiki_global_ext = 0
      vim.g.vimwiki_url_maxsave = 0
    end,
  },
  {
    "lukas-reineke/headlines.nvim",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup({
        vimwiki = {
            query = vim.treesitter.query.parse(
                "markdown",
                [[
                    (atx_heading [
                        (atx_h1_marker)
                        (atx_h2_marker)
                        (atx_h3_marker)
                        (atx_h4_marker)
                        (atx_h5_marker)
                        (atx_h6_marker)
                    ] @headline)

                    (thematic_break) @dash

                    (fenced_code_block) @codeblock

                    (block_quote_marker) @quote
                    (block_quote (paragraph (inline (block_continuation) @quote)))
                ]]
            ),
            headline_highlights = {
              "Headline1",
              "Headline2",
              "Headline3",
              "Headline4",
              "Headline5",
              "Headline6",
            },
            codeblock_highlight = "CodeBlock",
            dash_highlight = "Dash",
            dash_string = "-",
            quote_highlight = "Quote",
            quote_string = "┃",
            fat_headlines = true,
            fat_headline_upper_string = "▃",
            fat_headline_lower_string = "",
            treesitter_language = "markdown",
        }
      })
    end,
  },
}
