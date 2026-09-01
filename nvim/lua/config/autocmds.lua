local group = vim.api.nvim_create_augroup("dotfiles.external_changes", { clear = true })

local function in_command_line_window()
  return vim.fn.getcmdwintype() ~= ""
end

-- Codex, Git, generators, and formatters may change files outside Neovim.
vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  desc = "Reload files changed outside Neovim",
  callback = function()
    if in_command_line_window() then
      return
    end

    vim.cmd.checktime()
  end,
})

-- Also check a file whenever its buffer is entered.
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  desc = "Reload current file if changed outside Neovim",
  callback = function(ev)
    if in_command_line_window() or vim.bo[ev.buf].buftype ~= "" then
      return
    end

    vim.cmd(("checktime %d"):format(ev.buf))
  end,
})
