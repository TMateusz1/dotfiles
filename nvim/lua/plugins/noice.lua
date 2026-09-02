local function notification_history(retried)
  local config = require("noice.config")
  if not config.options.commands then
    if retried then
      vim.notify("Noice notification history is unavailable", vim.log.levels.ERROR)
    else
      vim.schedule(function()
        notification_history(true)
      end)
    end
    return
  end

  local integration = require("noice.integrations.fzf")
  local messages = require("noice.message.manager").get(config.options.commands.history.filter, {
    history = true,
    sort = true,
    reverse = true,
  })

  local entries = {}
  local lines = {}
  for _, message in ipairs(messages) do
    local entry = integration.entry(message)
    entries[message.id] = entry
    table.insert(lines, entry.display)
  end

  if #lines == 0 then
    vim.notify("No notification history")
    return
  end

  require("fzf-lua").fzf_exec(lines, {
    prompt = "Notifications❯ ",
    previewer = integration.previewer(entries),
    winopts = {
      title = " Notifications ",
      title_pos = "center",
      preview = {
        title = " Notification ",
        title_pos = "center",
      },
    },
    fzf_opts = {
      ["--no-multi"] = "",
      ["--no-sort"] = "",
      ["--with-nth"] = "2..",
    },
    actions = {
      default = function() end,
    },
  })
end

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  keys = {
    { "<leader>fn", notification_history, desc = "Notification history" },
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
