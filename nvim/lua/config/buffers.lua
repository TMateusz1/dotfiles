-- Closing or quitting with unsaved changes has to ask something. Neovim's own
-- `:confirm` dialog is not usable here: since 0.11.3 the prompt reaches the UI
-- through ext_cmdline, and noice's handling of that path is broken — the
-- question renders as a centred " Confirm " box that never accepts an answer
-- (folke/noice.nvim#1136, closed as not planned; #1185 confirms `routes`
-- cannot redirect it either). Do not simplify any of this back to `:confirm`.
--
-- `vim.fn.input()` is used rather than `vim.ui.select()` because the whole
-- question lives in the *cmdline* prompt, which noice renders for as long as
-- the prompt is open. A `vim.ui.select()` list is emitted as ordinary
-- messages, and with no notification backend installed those land in noice's
-- `mini` view, which times out after two seconds — the question would fade
-- while it is still being answered.
-- See docs/nvim.md#quitting-and-closing-with-unsaved-changes.

local M = {}

--- Loaded, ordinary buffers holding unsaved changes.
---@return integer[]
local function unsaved()
  return vim.tbl_filter(function(bufnr)
    return vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified and vim.bo[bufnr].buftype == ""
  end, vim.api.nvim_list_bufs())
end

---@param bufnr integer
---@return string
local function label(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return ("[No Name] (#%d)"):format(bufnr)
  end
  return vim.fn.fnamemodify(name, ":~:.")
end

--- Ask a one-line question in the cmdline and return the answer's first letter,
--- lowercased. Escape, Ctrl-C and an empty answer all mean "cancel".
---@param question string
---@return string
local function ask(question)
  local ok, answer = pcall(vim.fn.input, { prompt = question, cancelreturn = "c" })
  if not ok or answer == "" then
    return "c"
  end
  return answer:sub(1, 1):lower()
end

--- Close a buffer, asking what to do about unsaved changes first.
---@param bufnr? integer
function M.close(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if not vim.bo[bufnr].modified then
    vim.cmd(("bdelete %d"):format(bufnr))
    return
  end

  local answer = ask(("Save changes to %s? [y]es, [n]o, [c]ancel: "):format(label(bufnr)))
  if answer == "c" then
    return
  end

  -- Answering took time; the buffer may be gone by now.
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  if answer == "y" then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("write")
    end)
    vim.cmd(("bdelete %d"):format(bufnr))
  else
    vim.cmd(("bdelete! %d"):format(bufnr))
  end
end

--- Quit everything, asking what to do about unsaved changes first.
function M.quit_all()
  local dirty = unsaved()
  if #dirty == 0 then
    vim.cmd("quitall")
    return
  end

  local names = table.concat(vim.tbl_map(label, dirty), ", ")
  local answer = ask(("Unsaved: %s. [w]rite all and quit, [d]iscard and quit, [c]ancel: "):format(names))

  if answer == "w" then
    vim.cmd("wqall")
  elseif answer == "d" then
    vim.cmd("quitall!")
  end
end

return M
