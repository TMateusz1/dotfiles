return {
  "folke/which-key.nvim",
  version = "*",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 250,
    spec = {
      { "<leader>g", group = "Git UI" },
      { "<leader>G", group = "Git" },
      { "<leader>c", group = "Code" },
      { "<leader>cx", group = "Code lists" },
      { "<leader>cg", group = "Go" },
      { "<leader>cp", group = "Python" },
      { "<leader>ct", group = "Go struct tags" },
      { "<leader>f", group = "Find" },
      { "<leader>t", group = "Test" },
      { "<leader>u", group = "Toggle" },
      { "<leader>x", group = "Close buffers" },
      { "gs", group = "Surround", mode = { "n", "x", "o" } },
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
