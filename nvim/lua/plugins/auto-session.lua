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

    -- Auto-restore only when Neovim was given an argument — in practice
    -- `nvim .`. A bare `nvim` lands on the dashboard instead, which offers
    -- restoring as an explicit choice (`s`). This is read at spec load, well
    -- before VimEnter decides whether to restore. It gates the *automatic*
    -- restore only — `:SessionRestore` and auto-save are unaffected.
    auto_restore = vim.fn.argc(-1) > 0,
  },
}
