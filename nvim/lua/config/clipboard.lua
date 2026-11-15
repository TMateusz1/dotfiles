-- Deferred so the provider lookup doesn't slow startup.
vim.schedule(function()
  if vim.fn.has("mac") == 0 then
    -- VM over SSH/Zellij: copy via OSC52; paste from nvim's own register
    -- (Cmd+V covers the macOS clipboard). An OSC52 read would wait for a timeout.
    local osc52 = require("vim.ui.clipboard.osc52")
    local function paste()
      return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
    end
    vim.g.clipboard = {
      name = "OSC 52 (copy only)",
      copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
      paste = { ["+"] = paste, ["*"] = paste },
    }
  end
  vim.opt.clipboard = "unnamedplus"
end)
