-- THIS IS THE CORRECTED FILE - PASTE THIS

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- This part was already correct
    ensure_installed = {
      -- utils
      "lua",
      "vim",
      "json",
      "make",
      "yaml",
      -- TS & JS
      "javascript",
      "jsdoc",
      "typescript",
      -- go
      "go",
      "gomod",
      "gowork",
      "gosum",
    },
  },
}
