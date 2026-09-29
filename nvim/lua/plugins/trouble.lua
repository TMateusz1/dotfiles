return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    { "<leader>Td", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: Workspace diagnostics" },
    {
      "<leader>TD",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Trouble: Buffer diagnostics",
    },
    {
      "<leader>Ts",
      "<cmd>Trouble symbols toggle focus=false win.position=right win.size=45<cr>",
      desc = "Trouble: Document symbols",
    },
    { "<leader>Tr", "<cmd>Trouble lsp_references toggle<cr>", desc = "Trouble: LSP references" },
    { "<leader>Tq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: Check results (quickfix)" },
    {
      "<leader>Tf",
      function()
        require("trouble").toggle({ mode = require("trouble.sources.fzf").mode() })
      end,
      desc = "Trouble: Search results (fzf)",
    },
    { "<leader>Tl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: Location list" },
  },
  opts = {
    auto_preview = false,
    focus = true,
    win = {
      type = "split",
      position = "bottom",
      size = 12,
    },
    keys = {
      ["<esc>"] = "close",
    },
  },
}
