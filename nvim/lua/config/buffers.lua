local M = {}

-- Close a buffer through Neovim's native confirmation flow. Modified buffers
-- offer Save/Discard/Cancel; clean buffers close immediately.
---@param bufnr? integer
function M.close(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local ok, err = pcall(vim.cmd, ("confirm bdelete %d"):format(bufnr))
  if not ok and not tostring(err):find("E516:", 1, true) then
    error(err, 0)
  end
end

return M
