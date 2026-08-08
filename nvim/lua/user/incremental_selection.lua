-- Replacement for nvim-treesitter master's incremental_selection module,
-- removed in the main-branch rewrite with no official successor.
--   <C-space> (normal): select the treesitter node at the cursor
--   <C-space> (visual): expand selection to the parent node
--   <bs>      (visual): shrink selection to the previously selected node
local M = {}

-- Per-buffer stack of selected nodes; index 1 is the initial selection.
---@type table<integer, TSNode[]>
local stacks = {}

---@param node TSNode
---@return integer, integer, integer, integer  0-indexed inclusive (sr, sc, er, ec)
local function inclusive_range(node)
  local sr, sc, er, ec = node:range()
  -- treesitter ranges are end-exclusive; convert to inclusive cursor positions
  if ec == 0 then
    er = er - 1
    local last_line = vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1] or ""
    ec = math.max(#last_line, 1)
  end
  return sr, sc, er, ec - 1
end

---@param node TSNode
local function select_node(node)
  local sr, sc, er, ec = inclusive_range(node)
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! \27") -- leave visual mode before re-selecting
  end
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec, 0) })
end

---@param a TSNode
---@param b TSNode
---@return boolean
local function same_range(a, b)
  local a1, a2, a3, a4 = a:range()
  local b1, b2, b3, b4 = b:range()
  return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
end

function M.init_selection()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    return
  end
  stacks[vim.api.nvim_get_current_buf()] = { node }
  select_node(node)
end

function M.increment()
  local buf = vim.api.nvim_get_current_buf()
  local stack = stacks[buf]
  if not stack or #stack == 0 then
    return M.init_selection()
  end
  local node = stack[#stack]
  -- skip ancestors that cover the exact same range, so each press visibly grows
  local parent = node:parent()
  while parent and same_range(parent, node) do
    node = parent
    parent = node:parent()
  end
  if parent then
    table.insert(stack, parent)
    select_node(parent)
  else
    select_node(node) -- already at the root: keep selection
  end
end

function M.decrement()
  local buf = vim.api.nvim_get_current_buf()
  local stack = stacks[buf]
  if not stack or #stack <= 1 then
    return
  end
  table.remove(stack)
  select_node(stack[#stack])
end

function M.setup()
  vim.keymap.set("n", "<C-space>", M.init_selection, { desc = "Treesitter: init incremental selection" })
  vim.keymap.set("x", "<C-space>", M.increment, { desc = "Treesitter: grow selection" })
  vim.keymap.set("x", "<bs>", M.decrement, { desc = "Treesitter: shrink selection" })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("user_incremental_selection", { clear = true }),
    callback = function(args)
      stacks[args.buf] = nil
    end,
  })
end

return M
