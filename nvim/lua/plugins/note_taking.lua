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

      vim.keymap.set('n', '<leader>ww', '<cmd>lua vim.cmd.VimwikiIndex()<cr>', { desc = '[Vimwiki] Open vimwiki' })
      vim.keymap.set('n', '<leader>sc', function()
        if vim.g.created_notepad then
          vim.g.scratch_return_window = vim.fn.tabpagenr()
          vim.cmd("tabfirst")
        else
          vim.g.scratch_return_window = vim.fn.tabpagenr() + 1
          vim.cmd("0tabnew")
          vim.cmd("VimwikiMakeDiaryNote")
          vim.g.created_notepad = true
        end
      end, { desc = '[Vimwiki] Open scratch buffer' })
      vim.keymap.set('n', '<leader>bb', function()
        local return_window = vim.g.scratch_return_window
        if return_window then
          vim.cmd(return_window .. "tabn")
          vim.g.scratch_return_window = nil
        else
          vim.cmd("echo 'No return window set.'")
        end
      end, { desc = '[Vimwiki] Return to previous buffer from scratch' })
      vim.keymap.set('n', '<leader>ui', function()
        vim.cmd("VimwikiRebuildTags")
        vim.cmd("VimwikiGenerateTagLinks")
        vim.cmd("w")
      end, { desc = '[Vimwiki] Rebuild tags and generate tag links' })
      vim.keymap.set('n', '<leader>gf', '<cmd>lua vim.cmd.VimwikiTabnewLink()<cr>',
        { desc = '[Vimwiki] [G]o to [f]ile (new)' })
      vim.keymap.set('n', '<leader>=', '<Plug>VimwikiAddHeaderLevel<cr>', { desc = '[Vimwiki] Add header level' })
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons'
    },
    ft = { "markdown", "vimwiki", "codecompanion" },
    config = function()
      require('render-markdown').setup({
        html = { enabled = false },
        latex = { enabled = false },
        render_modes = true,
        heading = {
          sign = false,
          -- icons = { "◉ ", "○ ", "✸ ", "✿ " },
        },
        code = {
          sign = false,
          width = "block",
          right_pad = 1,
        },
      })
      vim.treesitter.language.register('markdown', 'vimwiki')
      -- icons
      vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = '#e28488', bg = '#402626', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = '#e3a589', bg = '#66493c', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = '#a1d182', bg = '#3d4f2f', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = '#62ccc4', bg = '#224541', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = '#75a5dc', bg = '#2b3d4f', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = '#e695ad', bg = '#6b454f', italic = false })
      -- background line
      vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { fg = '#e28488', bg = '#402626', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { fg = '#e3a589', bg = '#66493c', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { fg = '#a1d182', bg = '#3d4f2f', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { fg = '#62ccc4', bg = '#224541', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { fg = '#75a5dc', bg = '#2b3d4f', italic = false })
      vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { fg = '#e695ad', bg = '#6b454f', italic = false })
    end
  },
}
