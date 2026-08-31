-- Running tests without leaving the editor. neotest-golang drives `go test`
-- directly, so it needs no extra binary beyond the Go toolchain in mise.
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "fredrikaverpil/neotest-golang",
  },
  keys = {
    {
      "<leader>tt",
      function()
        require("neotest").run.run()
      end,
      desc = "Test: nearest",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Test: file",
    },
    {
      -- The directory of the current file — in Go that is exactly the package.
      "<leader>tp",
      function()
        require("neotest").run.run(vim.fn.expand("%:p:h"))
      end,
      desc = "Test: package",
    },
    {
      "<leader>ta",
      function()
        require("neotest").run.run(vim.uv.cwd())
      end,
      desc = "Test: all",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Test: summary panel",
    },
    {
      "<leader>to",
      function()
        require("neotest").output.open({ enter = true, auto_close = true })
      end,
      desc = "Test: output",
    },
    {
      "<leader>tS",
      function()
        require("neotest").run.stop()
      end,
      desc = "Test: stop run",
    },
  },
  config = function()
    require("neotest").setup({
      adapters = { require("neotest-golang") },
    })
  end,
}
