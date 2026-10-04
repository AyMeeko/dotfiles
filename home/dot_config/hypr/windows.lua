-- New normal application windows use the same large-center preset as the keybind.
-- Already-floating dialogs, utility windows and fullscreen apps keep their rules.
hl.on("window.open", function(window)
  if not window.mapped or window.floating or window.fullscreen ~= 0 or window.fullscreen_client ~= 0 then
    return
  end
  local address = window.address
  if not address:match("^0x%x+$") then
    return
  end
  hl.dispatch(hl.dsp.window.float({ action = "enable", window = "address:" .. address }))
  -- Address the new window explicitly so rapid launches never move the wrong one.
  hl.exec_cmd('python3 "$HOME/.config/hypr/window-presets.py" large --address ' .. address)
end)
