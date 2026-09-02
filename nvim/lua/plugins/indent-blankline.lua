return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    indent = {
      char = "▏",
      tab_char = "▏",
    },
    scope = {
      enabled = true,
      char = "▎",
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = { "alpha", "fzf", "help", "lazy", "neo-tree", "oil" },
      buftypes = { "nofile", "nowrite", "prompt", "quickfix", "terminal" },
    },
  },
}
