
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false
        }
      }
    },
  },
}
