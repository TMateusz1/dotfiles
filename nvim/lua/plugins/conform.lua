-- Formatting. Every formatter is a binary from the global mise config; conform
-- only orchestrates them. This is separate from hk.pkl, which formats *this
-- repo's own* files at commit time — see docs/linting.md.
return {
  "stevearc/conform.nvim",
  version = "*",
  event = { "BufWritePre" },
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      desc = "Format buffer",
    },
    {
      "<leader>us",
      function()
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Format on save " .. (vim.g.disable_autoformat and "off" or "on") .. " (global)")
      end,
      desc = "Toggle format on save (global)",
    },
    {
      "<leader>uS",
      function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify("Format on save " .. (vim.b.disable_autoformat and "off" or "on") .. " (buffer)")
      end,
      desc = "Toggle format on save (buffer)",
    },
  },
  opts = {
    formatters_by_ft = {
      go = { "goimports", "gofumpt" },
      lua = { "stylua" },
      python = { "ruff_format" },
      yaml = { "yamlfmt" },
      toml = { "taplo" },
      json = { "jq" },
      sh = { "shfmt" },
    },
    formatters = {
      taplo = {
        -- Conform passes buffer contents on stdin. Taplo needs the filename
        -- to apply file-scoped rules from the project's configuration.
        args = { "format", "--stdin-filepath", "$FILENAME", "-" },
        cwd = function(_, ctx)
          return vim.fs.root(ctx.dirname, { ".taplo.toml", "taplo.toml" }) or ctx.dirname
        end,
      },
    },
    default_format_opts = { lsp_format = "fallback" },
    -- On by default, but switchable. A buffer-local flag exists on top of the
    -- global one so a single file in someone else's repo can opt out without
    -- turning formatting off for the whole session.
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
  },
}
