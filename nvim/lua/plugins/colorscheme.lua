return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- load before other plugins that may reference its highlight groups
  opts = {
    flavour = "mocha",
    integrations = {
      gitsigns = true,
      indent_blankline = {
        enabled = true,
        scope_color = "lavender",
      },
      mini = { enabled = true },
      which_key = true,
    },
  },
  -- `config` (not `init`): lazy.nvim runs `init` *before* the plugin loads, so
  -- setting the colorscheme there applies it before `opts` ever reaches
  -- catppuccin.setup() — silently discarding every option here.
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
