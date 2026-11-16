return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "fredrikaverpil/neotest-golang",
      "marilari88/neotest-vitest",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({ runner = "gotestsum", go_test_args = { "-v", "-race", "-count=1" } }),
          require("neotest-vitest"),
        },
      })
    end,
    -- [t ]t belong to todo-comments.
    -- stylua: ignore
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest" },
      { "<leader>tT", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file" },
      { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run last" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Output panel" },
      { "[T", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
      { "]T", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
    },
  },
}
