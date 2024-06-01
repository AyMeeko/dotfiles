return {
  {
    "vimwiki/vimwiki",
    event = "VeryLazy",
    init = function()
      --vim.g.vimwiki_tag_format = {
        --pre = "\\(^[ -]*tags\\s*: .*\\)\\@<=",
        --pre_mark = "@",
        --post_mark = "",
        --sep = ">><<"
      --}
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
            bullet_highlights = {
              "@text.title.1.marker.markdown",
              "@text.title.2.marker.markdown",
              "@text.title.3.marker.markdown",
              "@text.title.4.marker.markdown",
              "@text.title.5.marker.markdown",
              "@text.title.6.marker.markdown",
            },
            bullets = { "◉", "○", "✸", "✿" },
            codeblock_highlight = "CodeBlock",
            dash_highlight = "Dash",
            dash_string = "-",
            quote_highlight = "Quote",
            quote_string = "┃",
            fat_headlines = true,
            fat_headline_upper_string = "▃",
            fat_headline_lower_string = "",
            treesitter_language = "markdown",
        },
        markdown = {
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
            bullet_highlights = {
              "@text.title.1.marker.markdown",
              "@text.title.2.marker.markdown",
              "@text.title.3.marker.markdown",
              "@text.title.4.marker.markdown",
              "@text.title.5.marker.markdown",
              "@text.title.6.marker.markdown",
            },
            bullets = { "◉", "○", "✸", "✿" },
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

      -- old, darker text
      --vim.api.nvim_set_hl(0, 'Headline1', {fg = '#cb7676', bg = '#402626', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline2', {fg = '#c99076', bg = '#66493c', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline3', {fg = '#80a665', bg = '#3d4f2f', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline4', {fg = '#4c9a91', bg = '#224541', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline5', {fg = '#6893bf', bg = '#2b3d4f', italic = false})
      --vim.api.nvim_set_hl(0, 'Headline6', {fg = '#d3869b', bg = '#6b454f', italic = false})

      -- new
      vim.api.nvim_set_hl(0, 'Headline1', {fg = '#e28488', bg = '#402626', italic = false})
      vim.api.nvim_set_hl(0, 'Headline2', {fg = '#e3a589', bg = '#66493c', italic = false})
      vim.api.nvim_set_hl(0, 'Headline3', {fg = '#a1d182', bg = '#3d4f2f', italic = false})
      vim.api.nvim_set_hl(0, 'Headline4', {fg = '#62ccc4', bg = '#224541', italic = false})
      vim.api.nvim_set_hl(0, 'Headline5', {fg = '#75a5dc', bg = '#2b3d4f', italic = false})
      vim.api.nvim_set_hl(0, 'Headline6', {fg = '#e695ad', bg = '#6b454f', italic = false})

      vim.api.nvim_set_hl(0, 'CodeBlock', {bg = '#31353f'})
    end,
  },
}
