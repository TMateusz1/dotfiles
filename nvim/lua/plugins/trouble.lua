return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    { "<leader>Td", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: Diagnostics" },
    {
      "<leader>TD",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Trouble: Buffer diagnostics",
    },
    { "<leader>Tq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: Quickfix list" },
    { "<leader>Tl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: Location list" },
  },
  opts = {},
}
