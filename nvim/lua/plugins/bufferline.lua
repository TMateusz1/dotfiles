local buffers = require("config.buffers")

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "<leader><leader>", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    {
      "<leader>xx",
      function()
        buffers.close()
      end,
      desc = "Buffers: Close current",
    },
    { "<leader>xX", "<cmd>BufferLineCloseOthers<cr>", desc = "Buffers: Close others" },
    { "<leader>xh", "<cmd>BufferLineCloseLeft<cr>", desc = "Buffers: Close to the left" },
    { "<leader>xl", "<cmd>BufferLineCloseRight<cr>", desc = "Buffers: Close to the right" },
    { "<leader>xp", "<cmd>BufferLinePickClose<cr>", desc = "Buffers: Pick one to close" },
  },
  config = function()
    require("bufferline").setup({
      highlights = require("catppuccin.special.bufferline").get_theme(),
      options = {
        close_command = buffers.close,
        right_mouse_command = buffers.close,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true,
          },
        },
      },
    })
  end,
}
