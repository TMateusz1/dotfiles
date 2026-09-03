return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      -- Not "catppuccin": that theme file was renamed to `catppuccin-nvim`
      -- upstream (see docs/nvim.md). It also reads the flavour of the applied
      -- colorscheme, so `flavour` in colorscheme.lua stays the single source of
      -- truth — unlike `catppuccin-mocha`, which hardcodes it a second time.
      theme = "catppuccin-nvim",
    },
  },
}
