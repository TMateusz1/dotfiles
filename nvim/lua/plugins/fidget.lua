return {
  "j-hui/fidget.nvim",
  lazy = false,
  opts = {
    notification = {
      override_vim_notify = true,
      -- Keep Fidget above lualine and Noice's raised command line.
      window = { y_padding = 2 },
    },
  },
}
