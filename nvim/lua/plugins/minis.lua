return {
  {
    "nvim-mini/mini.ai",
    version = "*",
    main = "mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        custom_textobjects = {
          -- Include comma-adjacent whitespace so `daa` leaves clean calls.
          a = ai.gen_spec.argument({ separator = "%s*,%s*" }),
        },
        mappings = {
          -- Preserve Neovim's native an/in Treesitter incremental selection.
          around_next = "aN",
          inside_next = "iN",
          around_last = "aL",
          inside_last = "iL",
        },
      }
    end,
  },
  {
    "nvim-mini/mini.icons",
    version = "*",
    main = "mini.icons",
    -- Not lazy-loaded, and ahead of the other UI plugins: bufferline, lualine
    -- and alpha ask for `nvim-web-devicons` by name, so the mock below has to
    -- be installed before any of them run their setup.
    lazy = false,
    priority = 900,
    opts = {},
    config = function(_, opts)
      local icons = require("mini.icons")
      icons.setup(opts)
      -- oil and which-key prefer mini.icons on their own. Everything else
      -- still requires "nvim-web-devicons"; this registers mini.icons under
      -- that module name so those plugins get the Catppuccin-themed icons
      -- without a devicons install. It is mini.icons' own supported API.
      icons.mock_nvim_web_devicons()
    end,
  },
  {
    "nvim-mini/mini.surround",
    version = "*",
    main = "mini.surround",
    event = "VeryLazy",
    opts = {},
  },
}
