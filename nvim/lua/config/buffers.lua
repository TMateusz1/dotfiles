-- The pinned Neovim/Noice versions cannot answer native `:confirm` prompts
-- (folke/noice.nvim#1136 and #1185). Keep this on vim.fn.input(): Noice renders
-- the save/discard/cancel question in its persistent command bar, and choices
-- can be submitted with one key. vim.ui.select() uses a separate fzf picker.
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

  local force = false
  if vim.bo[bufnr].modified then
    local answer = ask(("Save changes to %s? [y]es, [n]o, [c]ancel: "):format(label(bufnr)))
    if (answer ~= "y" and answer ~= "n") or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if answer == "y" then
      vim.api.nvim_buf_call(bufnr, vim.cmd.write)
    else
      force = true
    end
  end
  require("mini.bufremove").delete(bufnr, force)
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

--- Close the focused UI layer: float/utility window, buffer, or Neovim itself.
function M.smart_close()
  local winid = vim.api.nvim_get_current_win()
  local win_config = vim.api.nvim_win_get_config(winid)
  if win_config.relative ~= "" or win_config.external then
    vim.api.nvim_win_close(winid, true)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype == "trouble" then
    vim.cmd("Trouble close")
    return
  end
  if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].buflisted then
    local ordinary_windows = vim.tbl_filter(function(win)
      local config = vim.api.nvim_win_get_config(win)
      return config.relative == "" and not config.external
    end, vim.api.nvim_list_wins())
    if #ordinary_windows == 1 then
      M.quit_all()
    else
      vim.api.nvim_win_close(winid, false)
    end
    return
  end

  if #vim.fn.getbufinfo({ buflisted = 1 }) <= 1 then
    M.quit_all()
    return
  end

  M.close(bufnr)
end

return M
