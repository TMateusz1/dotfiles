-- Keep Zellij locked while this nvim pane has focus, so every key (Ctrl-o, Ctrl-p, ...) reaches nvim.
local M = {}

local pane = vim.env.ZELLIJ_PANE_ID and ("terminal_" .. vim.env.ZELLIJ_PANE_ID)
local timer = vim.uv.new_timer()
local leaving = false

function M.mode(mode)
  return vim.system({ "zellij", "action", "switch-mode", mode })
end

-- Cancel pending syncs so none can re-lock Zellij after VimLeave unlocks it.
function M.stop()
  leaving = true
  if timer then
    timer:stop()
  end
end

-- Focus events are unreliable: entering a tab sends FocusLost+FocusGained pairs, and leaving a
-- tab sends nothing. Ask Zellij which pane is focused instead.
function M.sync()
  if not (pane and timer) or leaving then
    return
  end
  timer:start(50, 0, function()
    vim.system({ "zellij", "action", "list-clients" }, { text = true }, function(r)
      if r.code ~= 0 or leaving then
        return
      end
      -- Lines: CLIENT_ID ZELLIJ_PANE_ID RUNNING_COMMAND
      local mine, other_nvim = false, false
      for line in r.stdout:gmatch("[^\n]+") do
        local id, cmd = line:match("^%S+%s+(%S+)%s*(.*)$")
        if id == pane then
          mine = true
        elseif cmd and cmd:find("nvim", 1, true) then
          other_nvim = true
        end
      end
      if mine then
        M.mode("locked")
      elseif not other_nvim then
        -- An nvim pane gaining focus owns the lock; don't race it by unlocking.
        M.mode("normal")
      end
    end)
  end)
end

return M
