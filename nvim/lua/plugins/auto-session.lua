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
  },
}
