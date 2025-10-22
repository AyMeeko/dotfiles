return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        filetypes = {
          vimwiki = false,
        },
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<tab>",
            accept_word = false,
            accept_line = false,
            next = "<C-n>",
            prev = "<C-p>",
            dismiss = "<C-]>",
          },
        },
      })
    end
  },
  {
    "folke/sidekick.nvim",
    opts = {
      -- Enable CLI tools with session persistence
      cli = {
        mux = {
          backend = "tmux", -- or "zellij" if you prefer
          enabled = true,
        },
        -- Pre-configured tools (install as needed)
        tools = {
          claude = { cmd = { "claude" } },
          opencode = {
            cmd = { "opencode" },
            -- this is a hack. Setting it to another theme wont work
            env = { OPENCODE_THEME = "system" },
          },
        },
        win = {
          keys = {
            normal_mode = { "<esc>", "stopinsert", mode = "t" }
          }
        }
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- Prioritize sidekick NES, fallback to copilot inline suggestions
          if require("sidekick").nes_jump_or_apply() then
            return       -- NES handled the tab
          end
          return "<Tab>" -- fallback to normal tab (copilot will handle via its keymap)
        end,
        expr = true,
        desc = "Sidekick NES or fallback to Tab",
        mode = { "i", "n" },
      },
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Toggle AI CLI",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        desc = "Select AI CLI Tool",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "Close AI CLI Session",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send Current Context to AI",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send File to AI",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Selection to AI",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Select AI Prompt",
      },
      -- Quick access to specific tools
      {
        "<leader>ac",
        function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
        desc = "Toggle Claude",
      },
    },
  },
}
