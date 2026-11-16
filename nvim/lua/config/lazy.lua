-- First launch clones lazy.nvim at this pinned tag; it then restores plugins from lazy-lock.json.
local version = "v11.17.5"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=" .. version,
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "folke/lazy.nvim", tag = version },
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
