return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    { "<leader>cxd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: Workspace diagnostics" },
    {
      "<leader>cxD",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Trouble: Buffer diagnostics",
    },
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=false win.position=right win.size=45<cr>",
      desc = "Trouble: Document symbols",
    },
    { "<leader>cxr", "<cmd>Trouble lsp_references toggle<cr>", desc = "Trouble: LSP references" },
    { "<leader>cxq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: Check results (quickfix)" },
    {
      "<leader>cxf",
      function()
        require("trouble").toggle({ mode = require("trouble.sources.fzf").mode() })
      end,
      desc = "Trouble: Search results (fzf)",
    },
    { "<leader>cxl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: Location list" },
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
      ["<leader>q"] = "close",
    },
  },
}
