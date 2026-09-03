return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>Gd", "<cmd>DiffviewOpen<cr>", desc = "Diff working tree" },
    { "<leader>GD", "<cmd>DiffviewOpen HEAD<cr>", desc = "Diff against last commit" },
    { "<leader>Gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>GH", "<cmd>DiffviewFileHistory<cr>", desc = "Repository history" },
    { "<leader>Gq", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
  },
  opts = {},
}
