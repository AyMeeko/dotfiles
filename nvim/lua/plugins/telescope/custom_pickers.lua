local action_layout = require('telescope.actions.layout')
local actions = require('telescope.actions')
local config = require('telescope.config')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local previewers = require('telescope.previewers')

local M = {}

M.vimwiki_tags = function(opts)
  opts = opts or {}

  local handle = io.popen("rg '^\\w+' .vimwiki_tags --json | jq -r '.data.submatches[]?.match.text' | sort | uniq")
  local results_str = handle:read("*a")
  handle:close()

  local results = {}
  for match in (results_str.."\n"):gmatch("(.-)".."\n") do
    table.insert(results, match);
  end

  pickers.new(opts, {
    prompt_title = 'Vimwiki tags',
    finder = finders.new_table({
      results = results,
    }),
    sorter = config.values.file_sorter(opts),
  }):find()
end

-- Fall back to find_files if git_files can't find a .git directory
M.project_files = function(opts)
  opts = opts or {}
  local ok = pcall(require "telescope.builtin".git_files, opts)
  if not ok then require "telescope.builtin".find_files(opts) end
end

return M
