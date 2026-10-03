# nvim config

Personal Neovim config. Plugins managed by [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstraps on first launch). Treesitter uses the nvim-treesitter `main` branch (the repo was archived 2026-04; `main` is the final/canonical API and requires the setup below).

## New machine setup

### 1. Deploy with chezmoi

Follow the [repository setup and migration guide](README.md). The managed source
is `home/dot_config/nvim`; chezmoi deploys regular files to `~/.config/nvim`:

```sh
chezmoi diff
chezmoi apply --interactive
```

### 2. Install required binaries

```sh
sudo pacman -S --needed neovim tree-sitter-cli ripgrep jq github-cli tmux nodejs yarn mise stylua
# neovim must be >= 0.12; tree-sitter-cli must be >= 0.26.1
```

Also install the standard build prerequisites if they are not already present:

```sh
sudo pacman -S --needed git curl tar base-devel
```

`base-devel` supplies a C compiler for parser builds. `tree-sitter-cli` is required because nvim-treesitter's `main` branch compiles parsers with it.

A [Nerd Font](https://www.nerdfonts.com/) must be installed and set as the terminal font (nvim-web-devicons, lualine separators).

### 3. Ruby via mise

```sh
mise use -g ruby@latest   # or whatever version; `mise which ruby` must succeed
```

### 4. First launch

```sh
nvim
```

- lazy.nvim clones itself + all plugins pinned by `lazy-lock.json`
- nvim-treesitter's build hook runs `:TSUpdate`; baseline parsers (python, ruby, json, lua, vim, vimdoc, query, markdown) install async on first start — needs network + tree-sitter CLI
- mason auto-installs LSP servers (eslint, graphql, lua_ls, marksman) after ~3s delay
- markdown-preview runs its `yarn install` build step

Opening a file whose parser isn't installed but is available auto-installs it (replacement for the old `auto_install = true`).

### 5. Manual one-time steps

Formatters used by conform.nvim are NOT mason-managed; install if needed:

```sh
# stylua is installed above for Lua
# oxfmt (js/ts/svelte): expected on PATH or via project node_modules
```

Ruby LSPs (rubocop, sorbet) run via `bundle exec` per-project — nothing global to install; they activate only when the gem is in the project's `Gemfile.lock`.

### 6. Verify

```vim
:checkhealth nvim-treesitter
:checkhealth vim.treesitter
:checkhealth provider
:Lazy
:Mason
```

Confirm that CtrlSF can discover ripgrep from `PATH`:

```sh
command -v rg
test -n "$(command -v rg)"
```

Confirm that the optional `factory_finder` integration safely falls back to the built-in LSP definition when its local checkout is absent:

```sh
test ! -d "$HOME/workspace/factory_finder.nvim" && rg -n "pcall\(require, 'factory_finder'\)|vim\.lsp\.buf\.definition" lua/plugins/lsp/go_to.lua
```

## Treesitter notes (post-archive migration)

- nvim-treesitter `main` has no `nvim-treesitter.configs`; highlight/indent are enabled per-buffer by a `FileType` autocmd in `lua/plugins/syntax.lua`
- Folds use the built-in `v:lua.vim.treesitter.foldexpr()` (`lua/user/settings.lua`)
- Incremental selection (`<C-space>` grow / `<bs>` shrink) was removed upstream; custom reimplementation lives in `lua/user/incremental_selection.lua`
- Textobjects (`vam`, `]m`, `;`/`,` repeat, etc.) use nvim-treesitter-textobjects `main` branch APIs
