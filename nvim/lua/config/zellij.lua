-- Keep Zellij locked while this nvim pane has focus, so every key (Ctrl-o, Ctrl-p, ...) reaches nvim.
local M = {}

local pane = vim.env.ZELLIJ_PANE_ID and ("%sterminal_" .. vim.env.ZELLIJ_PANE_ID .. "%s")
local timer = vim.uv.new_timer()

function M.mode(mode)
  return vim.system({ "zellij", "action", "switch-mode", mode })
end

-- Focus events are unreliable: entering a tab sends FocusLost+FocusGained pairs, and leaving a
-- tab sends nothing. Ask Zellij which pane is focused instead.
function M.sync()
  if not (pane and timer) then
    return
  end
  timer:start(50, 0, function()
    vim.system({ "zellij", "action", "list-clients" }, { text = true }, function(r)
      if r.code == 0 then
        M.mode((" " .. r.stdout):find(pane) and "locked" or "normal")
      end
    end)
  end)
end

return M
