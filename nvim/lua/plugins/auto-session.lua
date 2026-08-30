-- Capture this before startup plugins can rewrite the argument list. When the
-- only argument is a directory, neo-tree should open only after auto-session
-- has had the chance to restore that directory's session.
local launched_with_directory = false
if vim.fn.argc(-1) == 1 then
  local stat = vim.uv.fs_stat(vim.fn.argv(0) --[[@as string]])
  launched_with_directory = stat ~= nil and stat.type == "directory"
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

    -- Auto-restore only when Neovim was given an argument — in practice
    -- `nvim .`. A bare `nvim` lands on the dashboard instead, which offers
    -- restoring as an explicit choice (`s`). This is read at spec load, well
    -- before VimEnter decides whether to restore. It gates the *automatic*
    -- restore only — `:SessionRestore` and auto-save are unaffected.
    auto_restore = vim.fn.argc(-1) > 0,

    -- A directory argument with no saved session should open in neo-tree. Run
    -- this only after auto-session has tried the argument directory and found
    -- no session; checking from neo-tree itself would incorrectly check the
    -- shell's cwd for launches such as `nvim path/to/project`.
    no_restore_cmds = {
      function(is_startup)
        if is_startup and launched_with_directory then
          vim.cmd.Neotree()
        end
      end,
    },
  },
}
