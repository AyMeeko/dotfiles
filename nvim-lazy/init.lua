vim.g.mapleader = ','
vim.g.maplocalleader = ','

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
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    dependencies = {
      {'nvim-lua/plenary.nvim'},
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
  },

  -- syntax help
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-context',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- git signs in the gutter
  {'lewis6991/gitsigns.nvim'},

  -- lsp :)
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'L3MON4D3/LuaSnip'},
    }
  },

  -- better tab line
  {"rafcamlet/tabline-framework.nvim", dependencies = "nvim-tree/nvim-web-devicons"},

  -- better status line
  {'nvim-lualine/lualine.nvim', dependencies = 'nvim-tree/nvim-web-devicons'},

  ---- Run pytest in tmux pane
  {'vim-test/vim-test'},

  ---- Allow vim to send commands to tmux
  {'preservim/vimux'},

  -- window zoom
  {"anuvyklack/windows.nvim", dependencies = "anuvyklack/middleclass"},

  -- bubble text
  {'fedepujol/move.nvim'},

  -- easily add/delete/change "surroundings"
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  -- easy commenting/uncommenting
  {'scrooloose/nerdcommenter'},

  -- multiple cursors
  {'mg979/vim-visual-multi'},

  -- git integration
  {'tpope/vim-fugitive'},

  -- repeat motions
  {'tpope/vim-repeat'},

  {'norcalli/nvim-colorizer.lua'},

  -- grep
  {'dyng/ctrlsf.vim'},

})

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
vim.wo.relativenumber = true -- Relative line numbers
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
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.g.python3_host_prog = vim.fn.expand("$PYTHON3_HOST_PROG") -- Set python 3 provider

-- Remove trailing whitespace
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- Show trailing whitespace as a dot
vim.opt.list = true
vim.opt.listchars = {trail = '.'}

---- REMAPPINGS ----
-- Ctrl h and l to change buffers
vim.keymap.set("n", "<C-l>", vim.cmd.tabn)
vim.keymap.set("n", "<C-h>", vim.cmd.tabp)

-- Makes cursor not jump 'over' a line if it's wrapped to.a second line
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Clear last search
vim.keymap.set("n", "<leader>/", vim.cmd.nohlsearch)

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

-- Format JSON
vim.api.nvim_create_user_command("FormatJson", "%!jq .", {})
vim.keymap.set("n", "<leader>fj", vim.cmd.FormatJson)

-- Map za to <space> for folding/unfolding
vim.keymap.set("n", "<space>", "za")

-- Switch to previous buffer
vim.keymap.set("n", "<space><tab>", vim.cmd.bprev)

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
require('colorizer').setup()
SetColor() -- run at startup


---- CTRLSF ----
vim.g.ctrlsf_position = 'bottom'
vim.g.ctrlsf_winsize = '25%'
vim.g.ctrlsf_case_sensitive = 'smart'
vim.g.ctrlsf_default_root = 'project'
vim.g.ctrlsf_ackprg = '/opt/homebrew/bin/rg'

vim.keymap.set("n", "<C-f>f", ":CtrlSF ")

---- GIT ----
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gd", vim.cmd.Gvdiffsplit)

local Core_Fugitive = vim.api.nvim_create_augroup("Core_Fugitive", {})

local autocmd = vim.api.nvim_create_autocmd
autocmd("BufWinEnter", {
    group = Core_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "<leader>gb", function()
            vim.cmd.Git('blame')
        end, opts)
    end,
})

require("gitsigns").setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, opts)
        opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Navigation
    map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

    -- Actions
    map('n', '<leader>ha', ':Gitsigns stage_hunk<CR>')
    map('v', '<leader>ha', ':Gitsigns stage_hunk<CR>')

    map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
    map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
  end
}

---- LSP ----
local lsp = require("lsp-zero")

lsp.preset("recommended")

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "<leader>fd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

---- MOVE ----
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<C-j>', ':MoveLine(1)<CR>', opts)
vim.keymap.set('n', '<C-k>', ':MoveLine(-1)<CR>', opts)

vim.keymap.set('v', '<C-j>', ':MoveBlock(1)<CR>', opts)
vim.keymap.set('v', '<C-k>', ':MoveBlock(-1)<CR>', opts)

---- STATUS LINE ----
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'onedark'
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
  black = '#000000',
  tabs_text = '#c677dd',
  normal_mode = '#98c379',
  tab_bg = '#31353f',
  unselected_tab_bg = '#3e4452',
  unselected_tab_text = '#abb2bf',
}

-- TABS > file name[+]
local render = function(f)
  f.add({' TABS ', fg = colors.black, bg = colors.tabs_text})

  f.make_tabs(function(info)
    if info.index == 1 then
      f.add({' ', fg = colors.tabs_text, bg = info.current and colors.normal_mode or colors.unselected_tab_bg})
    elseif info.index > 1 then
      if info.current then
        f.add({' ', fg = colors.unselected_tab_bg, bg = colors.normal_mode})
      elseif info.after_current then
        f.add({' ', fg = colors.normal_mode, bg = colors.unselected_tab_bg})
      else
        f.add({' ', fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
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
        f.add({info.modified and '[+]', fg = colors.black, bg = colors.normal_mode})
      else
        f.add({info.modified and '[+]', fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
      end
      f.add({' ', bg = info.current and colors.normal_mode or colors.unselected_tab_bg})
    else
      f.add(info.modified and '[+]' or '[-]')
    end

    if info.last then
      f.add({'', fg = info.current and colors.normal_mode or colors.unselected_tab_bg, bg = colors.tab_bg})
    end

  end)

  f.add_spacer()
end

require('tabline_framework').setup { render = render }

---- TELESCOPE ----
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
--vim.keymap.set('n', '<C-f>f', builtin.live_grep, {})
vim.keymap.set('n', '<leader>bl', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Close telescope window with one Esc hit
local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    mappings = {
      i = { ["<esc>"] = actions.close }
    },
    preview = {
      hide_on_startup = true -- hide previewer when picker starts
    }
  }
})

---- TEST ----
vim.g['test#strategy'] = 'vimux'
vim.g['test#python#pytest#executable'] = 'pytest'

vim.keymap.set('n', '<leader>rt', vim.cmd.TestNearest, {})
vim.keymap.set('n', '<leader>rf', vim.cmd.TestFile, {})

---- TREE ----
require("nvim-tree").setup({
  view = {
    width = 55,
  }
})

vim.keymap.set("n", "<leader>n", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>f<space>", vim.cmd.NvimTreeFindFile)

-- if nvim open without args, open Tree view
-- if nvim open with file, open Tree view, move it to the left-most tab, refocus opened file
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      vim.cmd('NvimTreeToggle')
      vim.cmd('wincmd l')
      vim.cmd('q')
      vim.cmd('bdelete 1')
    else
      vim.cmd('tabnew ~/.nvim_tree')
      vim.cmd('tabm 0')
      vim.cmd('NvimTreeToggle')
      vim.cmd('bdelete 3')
      vim.cmd('tabn')
    end
  end,
})

---- TREESITTER ----
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "python", "javascript", "typescript", "c", "lua", "vim", "vimdoc", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

---- ZOOM WINDOW ----
local function cmd(command)
   return table.concat({ '<Cmd>', command, '<CR>' })
end

vim.keymap.set('n', '<leader>zw', cmd 'WindowsMaximize')
