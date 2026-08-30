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
    sections = {
      -- Default lualine_x, with Neovim's own progress summary in front of it.
      -- An empty component is dropped by lualine, so idle sessions look unchanged.
      lualine_x = { { vim.ui.progress_status, fmt = vim.trim }, "encoding", "fileformat", "filetype" },
    },
  },
}
