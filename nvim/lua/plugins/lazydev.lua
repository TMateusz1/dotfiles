-- Proper completion and hover for the Neovim API while editing this config.
-- Only loads for Lua buffers, and only configures lua_ls's library paths.
return {
  "folke/lazydev.nvim",
  version = "*",
  ft = "lua",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
}
