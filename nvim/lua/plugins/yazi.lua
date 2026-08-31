return {
  "mikavilpas/yazi.nvim",
  version = "*",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>e", "<cmd>Yazi<cr>", desc = "File explorer (current file)" },
    { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "File explorer (cwd)" },
  },
  opts = {
    -- Directory buffers belong to oil, which is already loaded at startup.
    open_for_directories = false,
    -- Square corners, deliberately not the global `winborder = "rounded"`
    -- this would otherwise inherit. Yazi draws its own status bar along the
    -- bottom of this window, and that bar is square (see
    -- docs/core_tools.md#yazi) to match tmux and lualine — a rounded frame
    -- around a square bar reads as a mismatch. This is the one float in the
    -- config that opts out; see docs/nvim.md.
    yazi_floating_window_border = "single",
  },
}
