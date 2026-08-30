local opt = vim.opt

opt.termguicolors = true -- required for the Catppuccin colorscheme's true-color palette

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
