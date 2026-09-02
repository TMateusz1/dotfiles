local function aerial_windows()
  local windows = {}
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if vim.bo[bufnr].filetype == "aerial" then
        table.insert(windows, winid)
      end
    end
  end
  return windows
end

-- `mksession` restores Aerial's nofile window as an empty placeholder. Because
-- Aerial is always opened immediately to the right of its source window, the
-- left neighbour is the source to reconnect through Aerial's public API.
local function restore_aerial(_, extra_data)
  if extra_data ~= "aerial" then
    return
  end

  for _, aerial_win in ipairs(aerial_windows()) do
    local source_win = vim.api.nvim_win_call(aerial_win, function()
      vim.cmd.wincmd("h")
      return vim.api.nvim_get_current_win()
    end)

    if source_win ~= aerial_win then
      require("aerial").open_in_win(aerial_win, source_win)
    end
  end
end

return {
  "rmagatti/auto-session",
  -- Must be loaded at startup: restoring happens on VimEnter, and there is
  -- no command or key to lazy-load from. It detects lazy.nvim and waits for
  -- it to finish (`lazy_support`, on by default).
  lazy = false,
  opts = {
    -- Don't create sessions for directories where a "project session" makes
    -- no sense — otherwise every `nvim` in $HOME or a temp dir leaves one
    -- behind. `~/Downloads` and `/` are auto-session's own suggestions.
    suppressed_dirs = { "~/", "~/Downloads", "/", "/tmp" },

    -- Preserve the complete split topology, including unnamed/new buffers and
    -- plugin-backed nofile windows, except neo-tree: its generated sidebar is
    -- transient and would restore as a dead placeholder. Aerial needs the
    -- extra-data hook below to turn its restored placeholder back into a live
    -- outline; ordinary file, help and terminal splits are handled directly
    -- by `mksession`.
    close_filetypes_on_save = { "neo-tree" },
    close_unsupported_windows = false,
    save_extra_data = function()
      if #aerial_windows() > 0 then
        return "aerial"
      end
    end,
    restore_extra_data = restore_aerial,

    -- Auto-restore only when Neovim was given an argument — in practice
    -- `nvim .`. A bare `nvim` lands on the dashboard instead, which offers
    -- restoring as an explicit choice (`s`). This is read at spec load, well
    -- before VimEnter decides whether to restore. It gates the *automatic*
    -- restore only — `:SessionRestore` and auto-save are unaffected.
    auto_restore = vim.fn.argc(-1) > 0,
  },
}
