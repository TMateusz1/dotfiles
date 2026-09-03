return {
  "MagicDuck/grug-far.nvim",
  cmd = { "GrugFar", "GrugFarWithin" },
  keys = {
    {
      "<leader>fR",
      function()
        require("grug-far").open()
      end,
      desc = "Find and replace",
    },
    {
      "<leader>fR",
      function()
        require("grug-far").with_visual_selection()
      end,
      mode = "x",
      desc = "Find and replace selection",
    },
  },
  opts = {},
}
