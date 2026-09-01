local opt = vim.opt

opt.termguicolors = true -- required for the Catppuccin colorscheme's true-color palette
opt.winborder = "rounded" -- consistent default for plugin and native floating windows
opt.title = true -- publish the current buffer title through tmux to the terminal tab/window

-- No reserved cmdline row: noice renders the cmdline as a float above the
-- statusline, so this lets lualine sit directly on tmux's status bar.
opt.cmdheight = 0

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

-- Select the remote provider before anything initializes the clipboard. Local
-- sessions still use Neovim's automatic pbcopy/wl-copy/xclip detection.
require("config.clipboard").setup()

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
