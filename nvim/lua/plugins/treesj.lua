return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    {
      "<leader>s",
      function()
        require("treesj").toggle()
      end,
      desc = "Toggle arguments layout",
    },
  },
  opts = {
    use_default_keymaps = false,
  },
}
