return {
  "stevearc/oil.nvim",
  version = "*",
  -- Not lazy-loaded: oil replaces netrw, so it has to be in place before the
  -- first directory buffer is created — including `nvim .` at startup.
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    {
      "<leader>o",
      function()
        require("oil").open_float()
      end,
      desc = "Open parent directory (float)",
    },
  },
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    view_options = {
      show_hidden = true,
    },
  },
}
