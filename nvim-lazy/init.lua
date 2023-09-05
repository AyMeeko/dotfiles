vim.g.mapleader = ","
vim.g.maplocalleader = ","

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "mrjones2014/legendary.nvim",
    version = "v2.1.0",
    -- since legendary.nvim handles all your keymaps/commands,
    -- its recommended to load legendary.nvim before other plugins
    priority = 10000,
    lazy = false,
    -- sqlite is only needed if you want to use frecency sorting
    dependencies = { "kkharji/sqlite.lua" }
  },

  {"stevearc/dressing.nvim", opts = {}},

  -- color scheme
  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").setup {
        transparent = true,
        diagnostics = {
          background = false,
        },
      }
    end
  },

  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}
    end,
  },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.2",
    dependencies = {
      {"nvim-lua/plenary.nvim"},
      {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
      {"benfowler/telescope-luasnip.nvim"},
    }
  },

  -- syntax help
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
  },

  -- git signs in the gutter
  {"lewis6991/gitsigns.nvim"},

  -- snippets
  {
    'hrsh7th/nvim-cmp',
    config = function ()
      require('cmp')
    end,
    dependencies = {"L3MON4D3/LuaSnip"}
  },
  {'saadparwaiz1/cmp_luasnip'},
  {
    "L3MON4D3/LuaSnip",
    version = "2.*",
    build = "make install_jsregexp",
    config = function()
      require("luasnip").config.set_config({
        history = true
      })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
    dependencies = {"rafamadriz/friendly-snippets"},
  },

  -- lsp :)
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- LSP Support
      {"neovim/nvim-lspconfig"},
      {"williamboman/mason.nvim"},
      {"williamboman/mason-lspconfig.nvim"},

      -- Autocompletion
      {"hrsh7th/nvim-cmp"},
      {"hrsh7th/cmp-nvim-lsp"},
      {"L3MON4D3/LuaSnip"},
    },
  },

  -- better tab line
  {"rafcamlet/tabline-framework.nvim", dependencies = "nvim-tree/nvim-web-devicons"},

  -- better status line
  {"nvim-lualine/lualine.nvim", dependencies = "nvim-tree/nvim-web-devicons"},

  ---- Run pytest in tmux pane
  {"vim-test/vim-test"},

  ---- Allow vim to send commands to tmux
  {"preservim/vimux"},

  -- window zoom
  {"anuvyklack/windows.nvim", dependencies = "anuvyklack/middleclass"},

  -- bubble text
  {"fedepujol/move.nvim"},

  -- easily add/delete/change "surroundings"
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },

  -- easy commenting/uncommenting
  {"scrooloose/nerdcommenter"},

  -- multiple cursors
  {"mg979/vim-visual-multi"},

  -- git integration
  {"tpope/vim-fugitive"},

  -- repeat motions
  {"tpope/vim-repeat"},

  {"norcalli/nvim-colorizer.lua"},

  -- grep
  {"dyng/ctrlsf.vim"},

  -- better python identation
  {"Vimjas/vim-python-pep8-indent"},

  -- open current file in GHE
  {"almo7aya/openingh.nvim"}
})

require("legendary").setup({
  keymaps = {
    -- General vim keymaps --
    {"<C-l>", vim.cmd.tabn, description = "Tab next"},
    {"<C-h>", vim.cmd.tabp, description = "Tab previous"},
    {"<leader>/", vim.cmd.nohlsearch, description = "Clear last search"},
    {"<leader><tab>", vim.cmd.bprev, description = "Switch to previous buffer"},
    {"<leader>fj", description = "Format Json"},
    {"<space>", description = "Toggle Fold"},

    -- Plugin keymaps --
    {"<leader>fk", ":Legendary<CR>", description = "Open Legendary"},
    {"<C-f>f", ":CtrlSF ", description = "Launch CtrlSF"},
    {"<leader>fs", ":Telescope luasnip<CR>", description = "[F]ind [S]nippet"},
    {"<leader>gs", vim.cmd.Git, description = "[Git] [G]it [S]tatus"},
    {"<leader>gd", vim.cmd.Gvdiffsplit, description = "[Git] [G]it [D]iff"},
    {
      "<leader>gb", function()
        vim.cmd.Git("blame")
      end,
      description = "[Git] [G]it [B]lame"},

    ---- MOVE ----
    {
      "<C-j>",
      { n = ":MoveLine(1)<CR>", v = ":MoveBlock(1)<CR>"},
      description = "Bubble Text Down",
      opts = {noremap = true, silent = true}
    },
    {
      "<C-k>",
      { n = ":MoveLine(-1)<CR>", v = ":MoveBlock(-1)<CR>"},
      description = "Bubble Text Up",
      opts = {noremap = true, silent = true}
    },

    ---- TELESCOPE ----
    {
      "<C-p>", function()
        require("telescope.builtin").git_files()
      end,
      description = "Fuzzy search git files"
    },
    {
      "<leader>ff", function()
        require("telescope.builtin").find_files()
      end,
      description = "Fuzzy search [f]ind [f]iles"
    },
    {
      "<leader>bl", function()
        require("telescope.builtin").buffers()
      end,
      description = "Open [b]uffer [l]ist"
    },
    {
      "<leader>fh", function()
        require("telescope.builtin").help_tags()
      end,
      description = "[F]ind [H]elp tags"
    },

    ---- VIM-TEST ----
    {
      "<leader>rt", function()
        vim.cmd.TestNearest()
      end,
      description = "[Test] [R]un [T]est"
    },
    {
      "<leader>rf", function()
        vim.cmd.TestFile()
      end,
      description = "[Test] [R]un [F]ile"
    },

    ---- NVIM TREE ----
    {
      "<leader>t", function()
        vim.cmd.NvimTreeToggle()
      end,
      description = "Toggle Nvim Tree"
    },
    {
      "<leader>f<space>", function()
        vim.cmd.NvimTreeFindFile()
      end,
      description = "Find Current File in Nvim Tree"
    },

    ---- ZOOM WINDOW ----
    {
      "<leader>zw", function()
        require('windows').setup()
        vim.cmd.WindowsMaximize()
      end,
      description = "[Z]oom into [W]indow"
    },

    ---- LSP ----
    {
      "]d", function()
        vim.diagnostic.goto_next()
      end,
      description = "[LSP] Next Diagnostic"
    },
    {
      "[d", function()
        vim.diagnostic.goto_prev()
      end,
      description = "[LSP] Previous Diagnostic"
    },
    {
      "<leader>fd", function()
        vim.lsp.buf.definition()
        vim.cmd("norm zz")
      end,
      description = "[LSP] [F]ind [D]efinition"
    },
    {
      "<leader>fr", function()
        vim.lsp.buf.references()
      end,
      description = "[LSP] [F]ind [R]eferences"
    },
    {
      "<leader>vd", function()
        vim.diagnostic.open_float()
      end,
      description = "[LSP] [V]iew [D]iagnostic"
    },
    {
      "<leader>rs", function()
        vim.lsp.buf.rename()
      end,
      description = "[LSP] [R]ename [S]ymbol"
    },
    {
      "<leader>hi", function()
        vim.lsp.buf.hover()
      end,
      description = "[LSP] [H]over [I]nformation"
    },

    ---- GIT SIGNS -----
    {
      "<leader>ga", function()
        vim.cmd.Gitsigns("stage_hunk")
      end,
      mode = { "n", "v" },
      description = "[Git signs] [G]it [A]dd"
    },
    {
      "<leader>gp", function()
        vim.cmd.Gitsigns("preview_hunk")
      end,
      description = "[Git signs] [G]it [P]review"
    },
    {"]c", description = "Next hunk"},
    {"[c", description = "Previous hunk"},
  }
})

---- ADDITIONAL KEYMAPS (on_attach and autocmds----
---- NVIM TREE ----
-- if nvim open without args, open Tree view
-- if nvim open with file, open Tree view, move it to the left-most tab, refocus opened file
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      vim.cmd("NvimTreeToggle")
      vim.cmd("wincmd l")
      vim.cmd("q")
      vim.cmd("bdelete 1")
    else
      vim.cmd("tabnew ~/.nvim_tree")
      vim.cmd("tabm 0")
      vim.cmd("NvimTreeToggle")
      vim.cmd("bdelete 3")
      vim.cmd("tabn")
    end
  end,
})

---- GIT SIGNS ----
require("gitsigns").setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, opts)
        opts = vim.tbl_extend("force", {noremap = true, silent = true}, opts or {})
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Navigation
    map("n", "]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
    map("n", "[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })
  end
}

-- Makes cursor not jump 'over' a line if it's wrapped to.a second line
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- make command line work with emacs style editing
vim.keymap.set("c", "<C-a>", "<Home>")
vim.keymap.set("c", "<C-e>", "<End>")
vim.keymap.set("c", "<M-f>", "<S-Right>")
vim.keymap.set("c", "<M-b>", "<S-Left>")

-- Allow variations of wq and qa
vim.api.nvim_create_user_command("WQ", "wq", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
vim.api.nvim_create_user_command("Q", "q", {})

-- Put Y back for yanking
vim.keymap.set("n", "Y", "yy", { noremap = true })

-- Format JSON
vim.api.nvim_create_user_command("FormatJson", "%!jq .", {})
vim.keymap.set("n", "<leader>fj", vim.cmd.FormatJson)

-- Map za to <space> for folding/unfolding
vim.keymap.set("n", "<space>", "za")

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.hlsearch = true -- Set highlight on search
vim.o.ignorecase = true -- Case-insensitive searching
vim.o.smartcase = true -- UNLESS \C or capital in search

-- Tabs
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2

vim.wo.number = true -- Make line numbers default
vim.o.mouse = 'a' -- Enable mouse mode
vim.o.undofile = true -- Save undo history

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set no compatible for Unimpaired?
vim.o.compatible = false

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

vim.opt.colorcolumn = "100"

-- Always show the gutter
vim.opt.signcolumn = "yes"

-- Folding :)
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldmethod = "expr"
vim.opt.foldlevel = 99

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", {clear = true})
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

vim.g.python3_host_prog = vim.fn.expand("$PYTHON3_HOST_PROG") -- Set python 3 provider

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- Show trailing whitespace as a dot
vim.opt.list = true
vim.opt.listchars = {trail = "."}

---- COLORS ----
vim.opt.termguicolors = true
vim.opt.background = "dark"

function SetColor(color)
    color = color or "onedark"
    vim.cmd.colorscheme(color)
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    --vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { bg = "none" })
end

-- must be set after vim.opt.termguicolors
require("colorizer").setup()
SetColor() -- run at startup

---- CTRLSF ----
vim.g.ctrlsf_position = "bottom"
vim.g.ctrlsf_winsize = "25%"
vim.g.ctrlsf_case_sensitive = "smart"
vim.g.ctrlsf_default_root = "project"
vim.g.ctrlsf_ackprg = "/opt/homebrew/bin/rg"

---- LSP ----
local lsp = require("lsp-zero").preset("recommended")

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = "E",
        warn = "W",
        hint = "H",
        info = "I"
    }
})

lsp.on_attach(function(client, bufnr)
  require("callbacks")
end)

require("lspconfig").pylsp.setup({
  settings = {
      pylsp = {
      configurationSources = {"pylint", "flake8"},
      plugins = {
        pylint = { enabled = true },
        flake8 = { enabled = true },
        isort = { enabled = true },
        pycodestyle = { enabled = false },
        mccabe = { enabled = false},
        pyflakes = { enabled = true },
      }
    }
  }
})

lsp.setup()
vim.diagnostic.config({virtual_text = true})

---- STATUS LINE ----
require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "onedark"
  },
  sections = {
    lualine_a = {"mode"},
    lualine_b = {"branch", "diff"},
    lualine_c = {"filename"},
    lualine_x = {
      {"diagnostics", sources = {"nvim_lsp"}},
      "encoding",
      "fileformat",
      "filetype"
    },
    lualine_y = {"progress"},
    lualine_z = {"location"}
  }
}

vim.o.showmode = false -- hide status bar so there aren't two

---- TAB LINE ----
local colors = {
  black = "#000000",
  tabs_text = "#c677dd",
  normal_mode = "#98c379",
  tab_bg = "#31353f",
  unselected_tab_bg = "#3e4452",
  unselected_tab_text = "#abb2bf",
}

-- TABS > file name[+]
local render = function(f)
  f.add({" TABS ", fg = colors.black, bg = colors.tabs_text})

  f.make_tabs(function(info)
    if info.index == 1 then
      f.add({" ", fg = colors.tabs_text, bg = info.current and colors.normal_mode or colors.unselected_tab_bg})
    elseif info.index > 1 then
      if info.current then
        f.add({" ", fg = colors.unselected_tab_bg, bg = colors.normal_mode})
      elseif info.after_current then
        f.add({" ", fg = colors.normal_mode, bg = colors.unselected_tab_bg})
      else
        f.add({" ", fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
      end
    end

    if info.filename then
      local fn
      if info.filename == "NvimTree_2" then
        fn = "Tree"
      else
        fn = info.filename
      end
      if info.current then
        f.add({fn, fg = colors.black, bg = colors.normal_mode})
      else
        f.add({fn, fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
      end
      if info.current then
        f.add({info.modified and "[+]", fg = colors.black, bg = colors.normal_mode})
      else
        f.add({info.modified and "[+]", fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
      end
      f.add({' ', bg = info.current and colors.normal_mode or colors.unselected_tab_bg})
    else
      f.add(info.modified and "[+]" or "[-]")
    end

    if info.last then
      f.add({"", fg = info.current and colors.normal_mode or colors.unselected_tab_bg, bg = colors.tab_bg})
    end

  end)

  f.add_spacer()
end

require("tabline_framework").setup { render = render }

---- TELESCOPE ----
require("telescope").load_extension("fzf")
require('telescope').load_extension("luasnip")

-- Close telescope window with one Esc hit
local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    mappings = {
      i = {["<C-d>"] = "delete_buffer"},
      n = {["dd"] = "delete_buffer", ["q"] = actions.close},
      --i = { ["<esc>"] = actions.close }
    },
    preview = {
      hide_on_startup = true -- hide previewer when picker starts
    }
  }
})

---- TEST ----
vim.g["test#strategy"] = "vimux"
vim.g["test#python#pytest#executable"] = "pytest"

---- TREE ----
require("nvim-tree").setup({
  view = {
    width = 55,
  }
})

---- TREESITTER ----
require("nvim-treesitter.configs").setup {
  ensure_installed = { "python", "javascript", "typescript", "c", "lua", "vim", "vimdoc", "query" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

require("treesitter-context").setup{
  max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 1, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}

-- Give context line a background color to indicate inside a context
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#3e4556" })

---- SNIPPETS AND LSP AUTOCOMPLETE ---
local cmp = require('cmp')
local luasnip = require("luasnip")

cmp.setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
     { name = 'luasnip' },
  }, {
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
