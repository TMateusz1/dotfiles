-- Non-plugin keymaps. Plugin keymaps live in their specs under lua/plugins/.
local map = vim.keymap.set

-- Esc also closes LSP floats (hover, signature, diagnostics), from the buffer or inside the float.
map("n", "<Esc>", function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.w[win].lsp_floating_bufnr then
      pcall(vim.api.nvim_win_close, win, false)
    end
  end
  vim.cmd.nohlsearch()
end, { desc = "Close LSP float, clear search highlight" })

-- K is always an LSP hover float. Without a hover server, say so instead of falling back to
-- 'keywordprg' (:Man / run-help splits); :help buffers keep :help.
map("n", "K", function()
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) > 0 then
    vim.lsp.buf.hover()
  elseif vim.bo.filetype == "help" or vim.bo.filetype == "vim" then
    vim.cmd.help(vim.fn.expand("<cword>"))
  else
    vim.notify("No hover provider for " .. vim.bo.filetype, vim.log.levels.INFO)
  end
end, { desc = "Hover" })

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

map("x", "<", "<gv")
map("x", ">", ">gv")
map("n", "n", "nzzzv", { desc = "Next match" })
map("n", "N", "Nzzzv", { desc = "Prev match" })

map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
map("n", "<leader>uu", function()
  -- Built-in since 0.12, shipped as an opt package.
  vim.cmd.packadd("nvim.undotree")
  vim.cmd.Undotree()
end, { desc = "Undotree" })
