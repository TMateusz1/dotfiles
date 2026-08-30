return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
  },
  opts = {
    filesystem = {
      -- Opening a directory after neo-tree has loaded uses neo-tree instead
      -- of netrw. Startup directory arguments are coordinated by
      -- auto-session's `no_restore` hook.
      hijack_netrw_behavior = "open_default",
      window = {
        position = "left",
        mappings = {
          -- Closes the tree after opening a file, but not a directory (which
          -- <cr> otherwise just expands/collapses) — <C-v>/<C-s> below stay
          -- on the plain built-in commands, which never auto-close.
          ["<cr>"] = function(state)
            local node = state.tree:get_node()
            require("neo-tree.sources.filesystem.commands").open(state)
            if node.type ~= "directory" then
              require("neo-tree.command").execute({ action = "close" })
            end
          end,
          ["<C-v>"] = "open_vsplit",
          ["<C-s>"] = "open_split",
        },
      },
    },
  },
}
