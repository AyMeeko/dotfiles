-- Invoked by chezmoi once, after restoring the pinned plugins.
local function fail(message)
  vim.api.nvim_err_writeln(message)
  vim.cmd("cquit 1")
end

local parsers = { "python", "ruby", "json", "lua", "vim", "vimdoc", "query", "markdown" }
require("nvim-treesitter").install(parsers):wait(300000)
for _, lang in ipairs(parsers) do
  if not vim.treesitter.language.add(lang) then fail("Parser installation failed: " .. lang) end
end
require("lazy").load({ plugins = { "nvim-lspconfig" } })
local registry = require("mason-registry")
local refreshed = false
registry.refresh(function() refreshed = true end)
if not vim.wait(120000, function() return refreshed end, 100) then
  fail("Mason registry refresh timed out")
end
local packages = { "eslint-lsp", "graphql-language-service-cli", "lua-language-server", "marksman" }
for _, name in ipairs(packages) do
  local package = registry.get_package(name)
  if not package:is_installed() and not package:is_installing() then
    package:install()
  end
end
if not vim.wait(300000, function()
  for _, name in ipairs(packages) do
    local package = registry.get_package(name)
    if not package:is_installed() or package:is_installing() then return false end
  end
  return true
end, 1000) then
  fail("LSP installation failed or timed out; inspect :Mason and rerun chezmoi apply")
end
