-- Baseline parsers installed at startup (replaces master-branch `ensure_installed`)
local ensure_installed = { "python", "ruby", "json", "lua", "vim", "vimdoc", "query", "markdown" }

-- Languages where treesitter highlighting stays off (was highlight.disable for html/markdown)
local highlight_disabled = { html = true, markdown = true }

return {
  { "Vimjas/vim-python-pep8-indent", ft = "python" },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- main branch does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- Install baseline parsers (async; no-op when already installed)
      ts.install(ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(args.match) or args.match

          local function enable()
            if not highlight_disabled[lang] then
              vim.treesitter.start(buf, lang)
              if lang == "python" then
                -- keep regex syntax alongside treesitter
                -- (was additional_vim_regex_highlighting = {"python"}); 'ON' must be uppercase.
                -- Deferred: during startup, later FileType machinery re-clears 'syntax'
                -- for the file given on the cmdline; scheduling lands after that.
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(buf) then
                    vim.bo[buf].syntax = "ON"
                  end
                end)
              end
            end
            -- was indent = true (indentation is experimental on main)
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end

          if vim.treesitter.language.add(lang) then
            enable()
          elseif vim.tbl_contains(ts.get_available(), lang) then
            -- was auto_install = true: fetch missing parser, then enable
            ts.install(lang):await(function()
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) and vim.treesitter.language.add(lang) then
                  enable()
                end
              end)
            end)
          end
        end,
      })

      require("user.incremental_selection").setup()
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        },
        move = {
          set_jumps = true, -- whether to set jumps in the jumplist
        },
      })

      -- Select textobjects (capture groups defined in textobjects.scm)
      local ts_select = require("nvim-treesitter-textobjects.select")
      local select_maps = {
        ["a="] = { "@assignment.outer", "Select outer part of an assignment" },
        ["i="] = { "@assignment.inner", "Select inner part of an assignment" },
        ["l="] = { "@assignment.lhs", "Select left hand side of an assignment" },
        ["r="] = { "@assignment.rhs", "Select right hand side of an assignment" },

        ["aa"] = { "@parameter.outer", "Select outer part of a parameter/argument" },
        ["ia"] = { "@parameter.inner", "Select inner part of a parameter/argument" },

        ["ai"] = { "@conditional.outer", "Select outer part of a conditional" },
        ["ii"] = { "@conditional.inner", "Select inner part of a conditional" },

        ["al"] = { "@loop.outer", "Select outer part of a loop" },
        ["il"] = { "@loop.inner", "Select inner part of a loop" },

        ["af"] = { "@call.outer", "Select outer part of a function call" },
        ["if"] = { "@call.inner", "Select inner part of a function call" },

        ["am"] = { "@function.outer", "Select outer part of a method/function definition" },
        ["im"] = { "@function.inner", "Select inner part of a method/function definition" },

        ["ac"] = { "@class.outer", "Select outer part of a class" },
        ["ic"] = { "@class.inner", "Select inner part of a class" },

        ["ab"] = { "@block.outer", "Select outer part of a block" },
        ["ib"] = { "@block.inner", "Select inner part of a block" },
      }
      for lhs, spec in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          ts_select.select_textobject(spec[1], "textobjects")
        end, { desc = spec[2] })
      end

      -- Move to textobjects
      local ts_move = require("nvim-treesitter-textobjects.move")
      local move_maps = {
        { "]m", "goto_next_start",     "@function.outer", "Next function start" },
        { "]]", "goto_next_start",     "@class.outer",    "Next class start" },
        { "]M", "goto_next_end",       "@function.outer", "Next function end" },
        { "][", "goto_next_end",       "@class.outer",    "Next class end" },
        { "[m", "goto_previous_start", "@function.outer", "Previous function start" },
        { "[[", "goto_previous_start", "@class.outer",    "Previous class start" },
        { "[M", "goto_previous_end",   "@function.outer", "Previous function end" },
        { "[]", "goto_previous_end",   "@class.outer",    "Previous class end" },
      }
      for _, m in ipairs(move_maps) do
        vim.keymap.set({ "n", "x", "o" }, m[1], function()
          ts_move[m[2]](m[3], "textobjects")
        end, { desc = m[4] })
      end

      local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

      -- vim way: ; goes to the direction you were moving.
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

      -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
    end,
  },
}
