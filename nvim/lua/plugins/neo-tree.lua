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

local function open_buffer_and_close(state)
  require("neo-tree.sources.common.commands").open(state)
  require("neo-tree.command").execute({
    action = "close",
    source = "buffers",
  })
end

local function close_buffer(state)
  local node = state.tree:get_node()
  local bufnr = node and node.extra and node.extra.bufnr
  if bufnr then
    require("config.buffers").close(bufnr)
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
    {
      "<leader>b",
      function()
        require("neo-tree.command").execute({
          action = "focus",
          source = "buffers",
          position = "left",
        })
      end,
      desc = "Buffer explorer",
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
    buffers = {
      -- Sessions restore non-focused buffers as unloaded; keep them visible
      -- in the buffer sidebar rather than only showing buffers opened now.
      show_unloaded = true,
      window = {
        mappings = {
          -- Keep buffer selection and deletion on the same safe paths used by
          -- the filesystem picker and Bufferline.
          ["<CR>"] = open_buffer_and_close,
          ["d"] = close_buffer,
          ["bd"] = close_buffer,
        },
      },
    },
  },
}
