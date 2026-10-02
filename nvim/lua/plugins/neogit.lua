return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  dependencies = {
    "ibhagwan/fzf-lua",
    "sindrets/diffview.nvim",
  },
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Git status (Neogit)" },
  },
  opts = {
    kind = "tab",
    integrations = {
      fzf_lua = true,
      diffview = true,
    },
    mappings = {
      status = {
        ["<leader>q"] = "Close",
      },
    },
  },
}
