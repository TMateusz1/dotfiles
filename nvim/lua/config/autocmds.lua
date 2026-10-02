local group = vim.api.nvim_create_augroup("dotfiles.autocmds", { clear = true })

-- Reload external edits on focus and buffer changes, without touching cmdwin.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group,
  desc = "Reload files changed outside Neovim",
  callback = function(ev)
    if vim.fn.getcmdwintype() ~= "" then
      return
    end
    if ev.event == "FocusGained" then
      vim.cmd.checktime()
    elseif vim.bo[ev.buf].buftype == "" then
      vim.cmd(("checktime %d"):format(ev.buf))
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 180 })
  end,
})
