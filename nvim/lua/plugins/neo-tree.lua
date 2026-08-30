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
  init = function()
    -- neo-tree replaces netrw for directory buffers (`hijack_netrw_behavior`
    -- below), but only once it has actually loaded — and `cmd`/`keys` above
    -- otherwise defer that until first use. So `nvim .` would still land in
    -- netrw. Load it eagerly for exactly that case: a single directory
    -- argument.
    if vim.fn.argc(-1) ~= 1 then
      return
    end
    local stat = vim.uv.fs_stat(vim.fn.argv(0) --[[@as string]])
    if not (stat and stat.type == "directory") then
      return
    end

    -- ...unless a session exists for this directory. That session restores
    -- its own windows, and the tree would sit on top of them. It has to be
    -- decided here, before neo-tree ever loads: closing the tree after the
    -- restore does not work, because neo-tree re-opens itself from `argv`
    -- once startup settles.
    local ok, auto_session = pcall(require, "auto-session")
    if ok then
      local has_session, exists = pcall(auto_session.session_exists_for_cwd)
      if has_session and exists then
        return
      end
    end

    require("neo-tree")
  end,
  opts = {
    filesystem = {
      -- Opening a directory opens neo-tree instead of netrw. This is
      -- upstream's default too, but stated explicitly because `init` above
      -- depends on it.
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
