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
      view = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
      file_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
      file_history_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
      option_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
      help_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        { "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
      },
    },
  },
}
