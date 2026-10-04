return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end, { desc = '[Gitsigns] Next hunk' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end, { desc = '[Gitsigns] Previous hunk' })

        map('n', '<leader>ga', gitsigns.stage_hunk, { desc = '[Gitsigns] Stage hunk' })
        map('v', '<leader>ga', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = '[Gitsigns] Stage hunk' })

        map('n', '<leader>gp', gitsigns.preview_hunk, { desc = '[Gitsigns] Preview hunk' })
      end
    })
  end,
}
