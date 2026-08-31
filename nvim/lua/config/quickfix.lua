-- Run deliberate, potentially slow checks without blocking Neovim and publish
-- their results as a fresh quickfix list. Callers own command construction and
-- output parsing so this stays useful for tools with structured output.
local M = {}

local running = {}

---@class DotfilesQuickfixRun
---@field name string Stable identifier used to prevent duplicate runs
---@field title string Quickfix list title
---@field cmd string[]
---@field cwd string
---@field parse fun(stdout: string): table[]
---@field accepted_exit_codes? table<integer, boolean>
---@field save? boolean Save the current buffer before starting
---@field on_complete? fun()

---@param opts DotfilesQuickfixRun
function M.run(opts)
  if running[opts.name] then
    vim.notify(opts.title .. " is already running", vim.log.levels.WARN)
    return
  end

  if opts.save then
    local ok, err = pcall(vim.cmd, "silent update")
    if not ok then
      vim.notify("Could not save before " .. opts.title .. ": " .. tostring(err), vim.log.levels.ERROR)
      return
    end
  end

  if vim.fn.executable(opts.cmd[1]) ~= 1 then
    vim.notify(opts.cmd[1] .. " is not executable", vim.log.levels.ERROR)
    return
  end

  running[opts.name] = true
  vim.notify(opts.title .. " started")

  vim.system(opts.cmd, { cwd = opts.cwd, text = true }, function(result)
    vim.schedule(function()
      running[opts.name] = nil

      local accepted = opts.accepted_exit_codes or { [0] = true }
      if not accepted[result.code] then
        local message = vim.trim(result.stderr or "")
        if message == "" then
          message = ("command exited with status %d"):format(result.code)
        end
        vim.notify(opts.title .. " failed: " .. message, vim.log.levels.ERROR)
        return
      end

      local ok, items = pcall(opts.parse, result.stdout or "")
      if not ok then
        vim.notify(opts.title .. " output could not be parsed: " .. tostring(items), vim.log.levels.ERROR)
        return
      end

      if opts.on_complete then
        opts.on_complete()
      end

      vim.fn.setqflist({}, " ", { title = opts.title, items = items })
      if #items > 0 then
        vim.cmd("copen")
        vim.notify(("%s finished with %d finding%s"):format(opts.title, #items, #items == 1 and "" or "s"))
      else
        vim.cmd("cclose")
        vim.notify(opts.title .. " finished cleanly")
      end
    end)
  end)
end

return M
