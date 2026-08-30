return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    -- Plugin default mappings already cover <C-h/j/k/l>; these add arrow-key
    -- equivalents, matching tmux.conf's own smart pane switching (which
    -- already binds both hjkl and the arrow keys the same way).
    { "<C-Left>", "<cmd>TmuxNavigateLeft<cr>", desc = "Move to left split/pane" },
    { "<C-Down>", "<cmd>TmuxNavigateDown<cr>", desc = "Move to lower split/pane" },
    { "<C-Up>", "<cmd>TmuxNavigateUp<cr>", desc = "Move to upper split/pane" },
    { "<C-Right>", "<cmd>TmuxNavigateRight<cr>", desc = "Move to right split/pane" },
  },
}
