return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- load before other plugins that may reference its highlight groups
  opts = {
    flavour = "mocha",
  },
  init = function()
    vim.cmd.colorscheme("catppuccin")
  end,
}
