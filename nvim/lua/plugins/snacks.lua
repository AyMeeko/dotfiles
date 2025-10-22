return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      preset = {
        keys = {
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "g", desc = "Git Files", action = ":lua Snacks.dashboard.pick('git_files')" },
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "s", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      }
    },
    indent = { enabled = true, },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      formatters = {
        file = {
          truncate = 150,
        }
      },
      layout = {
        preset = "ivy_split",
        preview = false,
      },
      matcher = {
        cwd_bonus = true,
        frecency = true,
        history_bonus = true
      },
      -- previewers = {
      --   diff = {
      --     cmd = { "delta" }
      --   }
      -- },
      win = {
        -- input = {keys = {["<Esc>"] = {"close", mode = {"n", "i"}}}}
        input = {
          keys = {
            ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<a-o>"] = "cycle_win",
          }
        },
        list = {
          keys = {
            ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<a-o>"] = "cycle_win",
          }
        },
        preview = {
          keys = {
            ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<a-o>"] = "cycle_win",
          }
        }
      },
    },
    quickfile = { enabled = true },
    scratch = {
      win = {
        width = 300
      }
    },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      }
    }
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- One place where lua_ls will yell at me about global Snacks
        local snacks = Snacks
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          snacks.debug.inspect(...)
        end
        _G.bt = function()
          snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        snacks.toggle.diagnostics():map("<leader>ud")
        snacks.toggle.line_number():map("<leader>ul")
        snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map(
          "<leader>uc")
        snacks.toggle.treesitter():map("<leader>uT")
        snacks.toggle.inlay_hints():map("<leader>uh")
        snacks.toggle.indent():map("<leader>ug")
        snacks.toggle.dim():map("<leader>uD")

        vim.keymap.set("n", "<C-p>", function() snacks.picker.smart() end, { desc = "Smart Find Files" })
        vim.keymap.set("n", "<leader>bl", function() snacks.picker.buffers() end, { desc = "[B]uffer [l]ist" })
        vim.keymap.set("n", "<leader>st", function() snacks.picker.grep() end, { desc = "[S]earch [t]ext" })
        vim.keymap.set("n", "<leader>n", function()
          snacks.picker.notifications()
        end, { desc = "[N]otification History" })

        -- find
        vim.keymap.set("n", "<leader>ff", function() snacks.picker.files() end, { desc = "[F]ind [F]iles" })
        vim.keymap.set("n", "<leader>fg", function() snacks.picker.git_files() end, { desc = "[F]ind [G]it Files" })
        vim.keymap.set("n", "<leader>fr", function() snacks.picker.recent() end, { desc = "[F]ind [R]ecent" })

        -- Grep
        vim.keymap.set({ "n", "x" }, "<leader>sw", function()
          snacks.picker.grep_word()
        end, { desc = "[S]earch [W]ord - Visual selection or word" })

        -- Other
        vim.keymap.set("n", "<leader>n", function() snacks.notifier.show_history() end, { desc = "Notification History" })
        vim.keymap.set({ "n", "v" }, "<leader>gh", function() snacks.gitbrowse() end, { desc = "Browse in [G]it[h]ub" })
        vim.keymap.set("n", "<leader>un", function() snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })
        vim.keymap.set("n", "<leader>.", function() snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
        vim.keymap.set("n", "<leader>gl", function()
          snacks.picker.git_log({ layout = { preview = true, fullscreen = true } })
        end, { desc = "[Git] [G]it [L]og" })
        vim.keymap.set("n", "<leader>ft", function()
          require("plugins.snacks.custom_pickers").vimwiki_tags()
        end, { desc = "[Vimwiki] [F]ind [T]ags" })
        vim.keymap.set("n", "<leader>bd", function() snacks.bufdelete() end, { desc = "[D]elete current [b]uffer" })
      end,
    })
  end,
}
