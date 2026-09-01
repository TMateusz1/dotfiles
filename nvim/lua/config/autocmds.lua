local group = vim.api.nvim_create_augroup("dotfiles.external_changes", { clear = true })

-- Codex, Git, generators, and formatters may change files outside Neovim.
vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  desc = "Reload files changed outside Neovim",
  callback = function()
    vim.cmd.checktime()
  end,
})

-- Also check a file whenever its buffer is entered.
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  desc = "Reload current file if changed outside Neovim",
  callback = function(ev)
    if vim.bo[ev.buf].buftype == "" then
      vim.cmd(("checktime %d"):format(ev.buf))
    end
  end,
})
