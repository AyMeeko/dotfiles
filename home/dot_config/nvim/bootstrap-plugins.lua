local config = require("lazy.core.config")
local lockfile = config.options.lockfile
local pinned = vim.fn.readfile(lockfile)
local lazy = require("lazy")
lazy.install({ wait = true, lockfile = true, show = false })
-- Installing missing plugins also rewrites entries for already installed plugins.
-- Restore the original snapshot before restoring those existing checkouts.
vim.fn.writefile(pinned, lockfile)
require("lazy.manage.lock")._loaded = false
lazy.restore({ wait = true, show = false })
vim.fn.writefile(pinned, lockfile)
for name, plugin in pairs(config.plugins) do
  assert(plugin._.installed, "Plugin not installed: " .. name)
  assert(not require("lazy.core.plugin").has_errors(plugin), "Plugin installation failed: " .. name)
end
