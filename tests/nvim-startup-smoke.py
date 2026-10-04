"""Check startup with installed plugins and conflicting stock specs present."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="dotfiles-nvim-startup-") as directory:
    root = Path(directory)
    config = root / "config/nvim"
    shutil.copytree(repo / "home/dot_config/nvim", config)
    # Stock Omarchy specs must not enter this standalone configuration.
    (config / "lua/plugins").mkdir(exist_ok=True)
    (config / "lua/plugins/disable-news-alert.lua").write_text(
        'return { "LazyVim/LazyVim", opts = { news = { lazyvim = false } } }\n')
    (config / "lua/plugins/unmanaged.lua").write_text(
        'error("Unmanaged plugin file was imported")\n')
    # A new personal spec must be discovered without changing a module list.
    (config / "lua/personal_plugins/new_spec.lua").write_text(
        'return { name = "discovery-test", dir = vim.fn.stdpath("config"), '
        'lazy = false, config = function() vim.g.personal_spec_discovered = true end }\n')
    lock = (config / "lazy-lock.json").read_bytes()
    env = dict(os.environ, XDG_CONFIG_HOME=str(root / "config"),
               XDG_CACHE_HOME=str(root / "cache"), XDG_STATE_HOME=str(root / "state"),
               DOTFILES_BOOTSTRAP="1")
    result = subprocess.run([
        "nvim", "--headless",
        '+lua vim.wait(200); assert(vim.v.errmsg == "", vim.v.errmsg); '
        'local p = require("lazy.core.config").plugins; '
        'assert(not p.LazyVim, "Stock LazyVim was loaded"); '
        'assert(vim.g.personal_spec_discovered, "New personal plugin was not discovered"); '
        'for _, name in ipairs({"catppuccin", "nvim-treesitter", "nvim-lspconfig", "snacks.nvim", "vim-fugitive"}) do '
        'assert(p[name], "Missing personal plugin: " .. name) end',
        "+qa",
    ], env=env, capture_output=True, text=True, timeout=60)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "Error" not in result.stderr, result.stderr
    assert "order of your" not in result.stderr, result.stderr
    assert (config / "lazy-lock.json").read_bytes() == lock, "Startup changed pinned plugins"
print("PASS: Neovim auto-discovers new personal specs, ignores stock LazyVim, and preserves pins")
