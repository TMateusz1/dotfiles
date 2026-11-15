-- lazy.nvim is provisioned by the dotfiles bootstrap, never cloned here.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  error("lazy.nvim missing: run `mise run bootstrap:plugins` from the dotfiles repo")
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "folke/lazy.nvim", tag = "v11.17.5" }, -- matches [bootstrap.repos]
    { import = "plugins" },
  },
  defaults = { lazy = true, version = false }, -- commits come from lazy-lock.json
  install = { missing = true, colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
  rocks = { enabled = false },
  ui = { border = "rounded" },
  performance = {
    rtp = { disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
  },
})
