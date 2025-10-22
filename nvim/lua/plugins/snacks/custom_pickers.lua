local M = {}

M.vimwiki_tags = function()
  local handle = io.popen("rg '^\\w+' .vimwiki_tags --json | jq -r '.data.submatches[]?.match.text' | sort | uniq")
  local results_str = handle:read("*a")
  handle:close()

  local results = {}
  for match in (results_str.."\n"):gmatch("(.-)".."\n") do
    table.insert(results, {text = match, preview = match});
  end

  return Snacks.picker.pick({
    source = "Vimwiki tags",
    items = results,
    format = "text",
  })
end

return M
