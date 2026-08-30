-- Clear search highlight on Esc, in addition to Esc's usual behavior.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
