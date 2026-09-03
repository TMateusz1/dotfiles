local function open_task_output_below()
  local task = require("overseer.task_list.sidebar").get():get_task_from_line()
  if not task then
    return
  end

  local bufnr = task:get_bufnr()
  if not bufnr then
    return
  end

  vim.cmd("belowright split")
  vim.api.nvim_win_set_buf(0, bufnr)
  require("overseer.util").set_term_window_opts()
  require("overseer.util").scroll_to_end(0)
end

return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerRun",
    "OverseerToggle",
  },
  keys = {
    { "<leader>mr", "<cmd>OverseerRun<cr>", desc = "Run mise task" },
    { "<leader>mt", "<cmd>OverseerToggle<cr>", desc = "Toggle task panel" },
  },
  opts = {
    task_list = {
      direction = "left",
      min_width = 0.5,
      max_width = 0.5,
      keymaps = {
        ["<C-s>"] = {
          callback = open_task_output_below,
          desc = "Open task output below",
        },
      },
    },
  },
}
