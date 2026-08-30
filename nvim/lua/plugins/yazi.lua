return {
  "mikavilpas/yazi.nvim",
  version = "*",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>e", "<cmd>Yazi<cr>", desc = "File explorer (current file)" },
    { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "File explorer (cwd)" },
  },
  opts = {
    -- Directory buffers belong to oil, which is already loaded at startup.
    open_for_directories = false,
  },
}
