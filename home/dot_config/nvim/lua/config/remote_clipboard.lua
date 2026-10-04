-- Both * and + address the ordinary system clipboard, matching macOS muscle
-- memory: "*y must be pasteable with Ctrl+V, not just middle-click.
-- Local Wayland sessions use wl-clipboard directly, including inside tmux.
-- SSH/herdr sessions additionally emit OSC 52 to reach the client clipboard;
-- without a local display, paste queries the terminal's clipboard via OSC 52.
local M = {}

local function proc_lines(pid, file)
  local ok, lines = pcall(vim.fn.readfile, "/proc/" .. pid .. "/" .. file)
  return ok and lines or {}
end

local function proc_ppid(pid)
  for _, line in ipairs(proc_lines(pid, "status")) do
    local ppid = line:match("^PPid:%s+(%d+)")
    if ppid then
      return tonumber(ppid)
    end
  end
end

local function ancestor_process_named(name)
  local pid = vim.fn.getpid()

  for _ = 1, 16 do
    local ppid = proc_ppid(pid)
    if not ppid or ppid <= 1 then
      return false
    end

    local comm = proc_lines(ppid, "comm")[1] or ""
    if comm:find(name, 1, true) then
      return true
    end

    pid = ppid
  end

  return false
end

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  local in_herdr = vim.env.HERDR_PANE_ID ~= nil or ancestor_process_named("herdr")
  local has_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1

  if has_wayland and not (in_ssh or in_herdr) then
    vim.g.clipboard = {
      name = "WaylandSystemClipboard",
      copy = {
        ["+"] = { "wl-copy", "--type", "text/plain" },
        ["*"] = { "wl-copy", "--type", "text/plain" },
      },
      paste = {
        ["+"] = { "wl-paste", "--no-newline" },
        ["*"] = { "wl-paste", "--no-newline" },
      },
      cache_enabled = 0,
    }
    return
  end

  if not (in_tmux or in_ssh or in_herdr) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local function copy()
    local emit = osc52.copy("+")

    return function(lines)
      if has_wayland then
        local cmd = { "wl-copy", "--type", "text/plain" }
        vim.fn.system(cmd, lines)
      end

      if vim.g.omarchy_remote_clipboard_osc52 ~= false then
        emit(lines)
      end
    end
  end

  local function paste()
    if not has_wayland then
      return osc52.paste("+")
    end

    return function()
      local cmd = { "wl-paste", "--no-newline" }
      local lines = vim.fn.systemlist(cmd, "", 1)
      return vim.v.shell_error == 0 and lines or {}
    end
  end

  vim.g.clipboard = {
    name = "OmarchyRemoteClipboard",
    copy = { ["+"] = copy(), ["*"] = copy() },
    paste = { ["+"] = paste(), ["*"] = paste() },
    cache_enabled = 0,
  }
end

return M
