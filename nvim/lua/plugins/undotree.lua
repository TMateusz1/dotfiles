return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Toggle undo tree" },
  },
  init = function()
    -- Keep both the history tree and its diff stacked in one right sidebar.
    vim.g.undotree_WindowLayout = 3
    vim.g.undotree_SplitWidth = 36
    vim.g.undotree_DiffpanelHeight = 10
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_ShortIndicators = 1
    vim.g.undotree_HelpLine = 0

    vim.g.undotree_TreeNodeShape = "●"
    vim.g.undotree_TreeVertShape = "│"
    vim.g.undotree_TreeSplitShape = "╱"
    vim.g.undotree_TreeReturnShape = "╲"
  end,
}
