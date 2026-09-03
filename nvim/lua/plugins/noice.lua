return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim", "ibhagwan/fzf-lua" },
  keys = {
    {
      "<leader>fn",
      function()
        require("noice").cmd("fzf")
      end,
      desc = "Message history",
    },
  },
  opts = {
    -- Use noice's full-width bar style for the cmdline rather than its
    -- centred popup, then lift it one row so it sits above the statusline.
    cmdline = {
      view = "cmdline",
      -- noice otherwise gives vim.fn.input() a separate centred popup. Keep
      -- save/discard/cancel questions in the same bottom bar as commands.
      format = { input = { view = "cmdline" } },
    },
    views = {
      -- The bar is a 1-row float. nui positions a float by its *content*
      -- height from the top of the editor grid, and that grid includes the
      -- statusline row, so the built-in "100%" lands on top of lualine.
      -- "99%" resolves to floor((lines - 1) * 0.99), which is exactly one
      -- row higher for every height up to ~102 rows. It has to be a
      -- percentage rather than `lines - 2`: nui re-evaluates percentages on
      -- each mount, so this survives a terminal resize, and noice caches
      -- view instances, so an absolute row could not be refreshed later.
      cmdline = { position = { row = "99%", col = 0 } },
    },
    notify = { enabled = false },
    lsp = { progress = { enabled = false } },
    presets = {
      -- Long messages open in a split instead of being truncated.
      long_message_to_split = true,
      -- Rounded border on K/gK's hover and signature-help popups, matching
      -- winborder everywhere else. Noice replaces vim.lsp.buf.hover and
      -- signature_help itself, so those two don't inherit winborder on
      -- their own — see docs/nvim.md's "Float borders" note.
      lsp_doc_border = true,
    },
  },
}
