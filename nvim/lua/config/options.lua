local opt = vim.opt

opt.termguicolors = true -- required for the Catppuccin colorscheme's true-color palette
opt.winborder = "rounded" -- consistent default for plugin and native floating windows

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Cursor
opt.cursorline = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Misc defaults
opt.wrap = false
opt.scrolloff = 8
opt.signcolumn = "yes"

-- Clipboard: `y` and `p` use the system clipboard, like any other editor.
opt.clipboard = "unnamedplus"

-- *Which* tool backs that register is Neovim's own detection, and it is right
-- locally (pbcopy on macOS, wl-copy/xclip on a Linux desktop). Over SSH there
-- is no local clipboard to talk to, so the two remote shapes are named
-- explicitly — both are Neovim's own built-in providers, not custom code:
--
--   * in tmux — the "tmux" provider: `tmux load-buffer -w -` to copy (tmux
--     then forwards it to the outer terminal's clipboard), and
--     `tmux refresh-client -l` + `tmux save-buffer -` to paste, which pulls
--     the outer terminal's clipboard into a tmux buffer and reads it back.
--   * no tmux — "osc52": Neovim talks to the terminal directly. Auto-detection
--     covers this case too, but only while 'clipboard' is empty, which it
--     isn't above — so it has to be asked for by name.
--
-- This has to happen before anything touches a clipboard register: the
-- provider is resolved once, on first use, and reads `g:clipboard` then.
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  vim.g.clipboard = vim.env.TMUX and "tmux" or "osc52"
end

-- What a saved session restores (see lua/plugins/auto-session.lua). This is
-- Neovim's default list plus `winpos` and `localoptions`; `localoptions` is
-- the one that carries per-buffer settings across a restart, without it only
-- the buffer list and window layout come back.
opt.sessionoptions = {
  "blank",
  "buffers",
  "curdir",
  "folds",
  "help",
  "tabpages",
  "winsize",
  "winpos",
  "terminal",
  "localoptions",
}
