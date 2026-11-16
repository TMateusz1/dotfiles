local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.confirm = true
opt.mouse = "a"

opt.termguicolors = true
opt.laststatus = 3
opt.showtabline = 2
opt.showmode = false
opt.cmdheight = 1
opt.pumheight = 10
opt.winborder = "rounded"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "", foldsep = " " }

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldtext = ""

opt.virtualedit = "block"
opt.completeopt = "menu,menuone,noselect"
opt.shortmess:append("WIcC")
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.spelllang = { "en" }
