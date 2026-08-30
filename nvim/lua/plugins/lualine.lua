return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "catppuccin",
    },
    sections = {
      -- Default lualine_x, with Neovim's own progress summary in front of it.
      -- An empty component is dropped by lualine, so idle sessions look unchanged.
      lualine_x = { { vim.ui.progress_status, fmt = vim.trim }, "encoding", "fileformat", "filetype" },
    },
  },
}
