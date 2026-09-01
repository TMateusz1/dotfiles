return {
  "stevearc/aerial.nvim",
  cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialInfo" },
  keys = {
    {
      "<leader>cs",
      "<cmd>AerialToggle! right<cr>",
      desc = "Toggle symbol outline",
    },
  },
  opts = {
    -- Aerial's auto-detection only checks nvim-web-devicons/lspkind, while
    -- this config deliberately uses mini.icons and a Nerd Font terminal.
    nerd_font = true,
    layout = {
      default_direction = "right",
      -- Double Aerial's default 20%/40-column ceiling and keep that width
      -- stable instead of shrinking the outline to its current contents.
      width = 0.25,
      min_width = 20,
      max_width = { 80, 0.4 },
      resize_to_content = false,
    },
  },
}
