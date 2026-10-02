-- Install editor tools before any LSP, formatter, or linter resolves PATH.
-- Package names here are Mason names; lsp.lua uses nvim-lspconfig names.
return {
  {
    "mason-org/mason.nvim",
    version = "^2.0.0",
    lazy = false,
    priority = 900,
    opts = {
      PATH = "prepend",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Language servers (Ruff and Buf also format and lint).
        { "gopls", version = "v0.23.0" },
        { "lua-language-server", version = "3.19.1" },
        { "json-lsp", version = "4.10.0" },
        { "yaml-language-server", version = "1.24.0" },
        { "helm-ls", version = "v0.5.4" },
        { "ruff", version = "0.16.8" },
        { "basedpyright", version = "1.40.1" },
        { "robotcode", version = "2.7.0" },
        { "rust-analyzer", version = "2026-09-21" },
        { "buf", version = "v1.73.0" },
        { "kotlin-lsp", version = "kotlin-lsp/v263.4702.0" },
        -- Standalone formatters.
        { "goimports", version = "v0.50.0" },
        { "gofumpt", version = "v0.12.0" },
        { "stylua", version = "v2.5.2" },
        { "yamlfmt", version = "v0.21.0" },
        { "taplo", version = "0.10.0" },
        { "jq", version = "jq-1.8.2" },
        { "shfmt", version = "v3.14.1" },
        -- Linters/checkers and Go editing utilities.
        { "hadolint", version = "v2.15.1" },
        { "golangci-lint", version = "v2.13.2" },
        { "mypy", version = "2.3.1" },
        { "gomodifytags", version = "v1.17.0" },
        { "impl", version = "v1.5.0" },
      },
      auto_update = false,
      run_on_start = true,
      integrations = {
        ["mason-lspconfig"] = false,
        ["mason-null-ls"] = false,
        ["mason-nvim-dap"] = false,
      },
    },
  },
}
