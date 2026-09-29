local close_keys = {
  { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
  { "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
}

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>Gd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree" },
    { "<leader>GD", "<cmd>DiffviewOpen HEAD<cr>", desc = "Diff against last commit" },
    { "<leader>Gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>GH", "<cmd>DiffviewFileHistory<cr>", desc = "Repository history" },
    { "<leader>Gq", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    { "<leader>GR", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Review branch changes against main" },
    { "<leader>Gm", "<cmd>DiffviewOpen origin/main...HEAD --imply-local<cr>", desc = "Diff branch work against main" },
  },
  opts = {
    keymaps = {
      view = close_keys,
      file_panel = close_keys,
      file_history_panel = close_keys,
      option_panel = close_keys,
      help_panel = close_keys,
    },
  },
}
