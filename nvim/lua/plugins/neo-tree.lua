local function nearest_existing_path()
  if vim.bo.buftype ~= "" then
    return vim.fn.getcwd()
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return vim.fn.getcwd()
  end

  while vim.uv.fs_stat(path) == nil do
    local parent = vim.fs.dirname(path)
    if parent == nil or parent == path then
      return vim.fn.getcwd()
    end
    path = parent
  end

  return path
end

local function open_and_close(state)
  local node = state.tree:get_node()
  require("neo-tree.sources.filesystem.commands").open(state)
  if node.type ~= "directory" then
    require("neo-tree.command").execute({
      action = "close",
      source = "filesystem",
    })
  end
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({
          action = "focus",
          source = "filesystem",
          position = "left",
          reveal_file = nearest_existing_path(),
        })
      end,
      desc = "File explorer (current file)",
    },
  },
  opts = {
    window = {
      position = "left",
    },
    filesystem = {
      -- Oil owns directory buffers (`nvim .`, `:edit .`, `-`); neo-tree is
      -- an explicit sidebar only.
      hijack_netrw_behavior = "disabled",
      window = {
        mappings = {
          ["<CR>"] = open_and_close,
          ["<C-CR>"] = "open",
          ["<C-v>"] = "open_vsplit",
          ["<C-s>"] = "open_split",
        },
      },
    },
  },
}
