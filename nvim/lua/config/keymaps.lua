-- Clear search highlight on Esc, in addition to Esc's usual behavior.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>W", "<cmd>write ++p<CR>", { desc = "Save file (create parent dirs)" })

-- Close the focused float, the current buffer, or Neovim when no other listed
-- buffer remains. See lua/config/buffers.lua for the unsaved-change flow.
vim.keymap.set("n", "<leader>q", function()
  require("config.buffers").smart_close()
end, { desc = "Smart close" })

-- Quit the complete editor through the same unsaved-aware flow used when
-- smart-close reaches the final buffer.
vim.keymap.set("n", "<leader>Q", function()
  require("config.buffers").quit_all()
end, { desc = "Smart quit all" })
