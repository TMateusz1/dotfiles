return {
  "christoomey/vim-tmux-navigator",
  -- Not lazy-loaded: the plugin defines its own <C-h/j/k/l> mappings when it
  -- loads, so deferring it would leave those keys unmapped until something
  -- else triggered the load.
  lazy = false,
  config = function()
    -- Arrow-key equivalents of the plugin's own <C-h/j/k/l> defaults, matching
    -- tmux.conf's smart pane switching (which binds both spellings the same
    -- way). Set here rather than via lazy's `keys`, which declares
    -- lazy-loading triggers and would contradict `lazy = false` above.
    local map = function(lhs, cmd, desc)
      vim.keymap.set("n", lhs, "<cmd>" .. cmd .. "<cr>", { silent = true, desc = desc })
    end

    map("<C-Left>", "TmuxNavigateLeft", "Move to left split/pane")
    map("<C-Down>", "TmuxNavigateDown", "Move to lower split/pane")
    map("<C-Up>", "TmuxNavigateUp", "Move to upper split/pane")
    map("<C-Right>", "TmuxNavigateRight", "Move to right split/pane")
  end,
}
