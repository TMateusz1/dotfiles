return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      -- Mocha by default; Latte when the terminal reports a light background.
      flavour = "auto",
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      term_colors = true,
      dim_inactive = { enabled = false },
      -- Listed explicitly: auto-detection probes vim.pack, which creates an empty pack dir.
      auto_integrations = false,
      default_integrations = false,
      lsp_styles = { underlines = { errors = { "undercurl" }, warnings = { "undercurl" } } },
      integrations = {
        aerial = true,
        blink_cmp = true,
        diffview = true,
        flash = true,
        gitsigns = true,
        grug_far = true,
        lsp_trouble = true,
        neotest = true,
        render_markdown = true,
        treesitter_context = true,
        which_key = true,
        snacks = { enabled = true, indent_scope_color = "lavender" },
        mini = { enabled = true },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
