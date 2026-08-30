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
