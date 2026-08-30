return {
  "folke/which-key.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    preset = "modern",
    delay = 250,
    spec = {
      { "<leader>f", group = "Find" },
      { "<leader>x", group = "Close buffers" },
    },
    win = {
      border = "rounded",
      padding = { 1, 2 },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer-local keymaps",
    },
  },
}
