return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
  },
  opts = {
    plugins = {
      -- Twilight has its own explicit toggle under <leader>ux.
      twilight = { enabled = false },
    },
  },
}
