return {
  "nvim-treesitter/nvim-treesitter",
  version = "*",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  build = ":TSUpdate",
  event = {"BufEnter"},
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {"python", "json", "lua", "vim", "vimdoc", "query", "markdown"},
      sync_install = false,
      auto_install = true,
      indent = true,
      highlight = {
        enable = true,
        disable = function(lang, buf)
          if lang == "html" then
            return true
          end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
    })
  end,
}
