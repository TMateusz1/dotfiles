-- Go helpers that gopls does not provide: struct tags and interface stubs.
-- The binaries (gomodifytags, impl) come from the global mise config, so
-- gopher's own installer is switched off — see docs/nvim.md#go.
return {
  "olexsmir/gopher.nvim",
  ft = "go",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    installation = false,
    commands = {
      go = "go",
      gomodifytags = "gomodifytags",
      impl = "impl",
    },
  },
  keys = {
    { "<leader>cta", "<cmd>GoTagAdd json<cr>", ft = "go", desc = "Go: add json tags" },
    { "<leader>cty", "<cmd>GoTagAdd yaml<cr>", ft = "go", desc = "Go: add yaml tags" },
    { "<leader>ctr", "<cmd>GoTagRm<cr>", ft = "go", desc = "Go: remove tags" },
    { "<leader>cI", "<cmd>GoImpl<cr>", ft = "go", desc = "Go: implement interface" },
    { "<leader>ce", "<cmd>GoIfErr<cr>", ft = "go", desc = "Go: expand if err" },
  },
}
