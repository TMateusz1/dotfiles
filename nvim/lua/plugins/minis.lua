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
    "nvim-mini/mini.surround",
    version = "*",
    main = "mini.surround",
    event = "VeryLazy",
    opts = {},
  },
}
