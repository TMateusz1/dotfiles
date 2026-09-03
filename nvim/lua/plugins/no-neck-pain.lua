return {
  "shortcuts/no-neck-pain.nvim",
  version = "*",
  cmd = "NoNeckPain",
  keys = {
    { "<leader>uz", "<cmd>NoNeckPain<cr>", desc = "Toggle zen mode" },
  },
  opts = {
    autocmds = {
      enableOnVimEnter = false,
      enableOnTabEnter = false,
    },
    mappings = { enabled = false },
    buffers = {
      colors = { background = "catppuccin-mocha" },
    },
  },
}
