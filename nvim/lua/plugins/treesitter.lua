-- Parsers installed by this config. This list is the single source of truth:
-- the FileType autocommand below turns highlighting on for whatever parser
-- Neovim resolves for a buffer, so there is no parallel filetype list to keep
-- in sync (and aliases like sh -> bash keep working for free).
local parsers = {
  -- Go, including the files that come with it
  "go",
  "gomod",
  "gosum",
  "gowork",
  "gotmpl",
  "helm", -- Helm templates: gotmpl inside YAML, used by helm-ls

  -- Rust
  "rust",

  -- JavaScript / TypeScript
  "javascript",
  "jsdoc",
  "typescript",
  "tsx",

  -- Shell
  "bash",

  -- Python, plus Robot Framework (.robot/.resource — Neovim already detects
  -- both as filetype `robot`, so no custom filetype rule is needed)
  "python",
  "robot",

  -- Data / config formats
  "toml",
  "json",
  "yaml",
  "xml",
  "ini",
  "csv",
  "sql",
  "dockerfile",
  "make",
  "markdown",
  "markdown_inline",
  "regex",
  "ssh_config",
  "editorconfig",

  -- git
  "diff",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "git_config",
  "git_rebase",

  -- Neovim's own surface: this repo's config is Lua, and `query` covers
  -- treesitter's own .scm query files
  "lua",
  "luadoc",
  "vim",
  "vimdoc",
  "query",
}

return {
  "nvim-treesitter/nvim-treesitter",
  -- The `main` branch is a full rewrite and the plugin's default branch; the
  -- old `master` API (`ensure_installed`, `highlight = { enable = true }`)
  -- does not exist here. See docs/nvim.md.
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
  },
  config = function()
    require("nvim-treesitter").setup()
    require("nvim-treesitter-textobjects").setup({
      move = { set_jumps = true },
    })

    local move = require("nvim-treesitter-textobjects.move")
    vim.keymap.set({ "n", "x", "o" }, "[f", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end, { desc = "Previous function" })
    vim.keymap.set({ "n", "x", "o" }, "]f", function()
      move.goto_next_start("@function.outer", "textobjects")
    end, { desc = "Next function" })

    -- Asynchronous, and a no-op for parsers already present.
    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Enable treesitter highlighting when a parser is available",
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang then
          return
        end
        -- Guard `start` itself, not just the language lookup: Neovim maps
        -- plenty of filetypes to a language name whose grammar isn't
        -- installed here (tex -> latex, and anything else outside the list
        -- above), and `start` raises for those. It also covers a parser that
        -- is still compiling on a first run.
        pcall(vim.treesitter.start, args.buf, lang)
      end,
    })
  end,
}
