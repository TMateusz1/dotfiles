return {
  "folke/which-key.nvim",
  version = "*",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 250,
    spec = {
      { "<leader>G", group = "Git" },
      { "<leader>T", group = "Trouble" },
      { "<leader>c", group = "Code" },
      { "<leader>cg", group = "Go" },
      { "<leader>ck", group = "Kubernetes" },
      { "<leader>cp", group = "Python" },
      { "<leader>ct", group = "Go struct tags" },
      { "<leader>f", group = "Find" },
      { "<leader>t", group = "Test" },
      { "<leader>u", group = "Toggle" },
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
