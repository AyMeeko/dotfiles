local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use('wbthomason/packer.nvim')

  -- color scheme
  use('navarasu/onedark.nvim')

  -- file tree
  use({
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional
    }
  })

  -- fuzzy finder
  use({
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    -- or                            , branch = '0.1.x',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}
    }
  })

  -- syntax help
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
  use('nvim-treesitter/nvim-treesitter-context')
  use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
  })

  -- git signs in the gutter
  use('lewis6991/gitsigns.nvim')

  -- lsp :)
  use({
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},
    }
  })

  -- better tab line
  use { "rafcamlet/tabline-framework.nvim",  requires = "kyazdani42/nvim-web-devicons" }

  -- better status line
  use({
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  })

  ---- Run pytest in tmux pane
  use('vim-test/vim-test')

  ---- Allow vim to send commands to tmux
  use('preservim/vimux')


  -- window zoom
  use({
    "anuvyklack/windows.nvim",
    requires = "anuvyklack/middleclass",
    config = function()
      require('windows').setup()
    end
  })

  -- bubble text
  use('fedepujol/move.nvim')

  -- easily add/delete/change "surroundings"
  use({
    'kylechui/nvim-surround',
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({})
    end
  })

  -- easy commenting/uncommenting
  use('scrooloose/nerdcommenter')

  -- multiple cursors
  use('mg979/vim-visual-multi')

  -- git integration
  use('tpope/vim-fugitive')

  -- repeat motions
  use('tpope/vim-repeat')

  use('norcalli/nvim-colorizer.lua')

  -- grep
  use('dyng/ctrlsf.vim')

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end

end)
