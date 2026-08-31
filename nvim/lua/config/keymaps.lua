-- Clear search highlight on Esc, in addition to Esc's usual behavior.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Quit all, prompting about unsaved changes. See lua/config/buffers.lua for
-- why this does not simply run `:confirm qall`.
vim.keymap.set("n", "<leader>qq", function()
  require("config.buffers").quit_all()
end, { desc = "Quit all" })
