-- Prettier when the project configures it, otherwise Biome.
local web = { "prettier", "biome-check", stop_after_first = true }

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format()
        end,
        mode = { "n", "x" },
        desc = "Format",
      },
    },
    opts = {
      default_format_opts = { lsp_format = "fallback", timeout_ms = 1500 },
      format_on_save = function(buf)
        if vim.g.autoformat == false or vim.b[buf].autoformat == false then
          return
        end
        return {}
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        yaml = { "yamlfmt" },
        javascript = web,
        javascriptreact = web,
        typescript = web,
        typescriptreact = web,
        json = web,
        jsonc = web,
        css = web,
        graphql = web,
        python = { "ruff_organize_imports", "ruff_format" },
        toml = { "taplo" },
        -- go, rust, markdown, dockerfile: LSP fallback (gopls+gofumpt, rustfmt, rumdl)
        -- helm: intentionally not formatted (templates break)
      },
      formatters = {
        prettier = { require_cwd = true }, -- only with a Prettier config in the project
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle({
            name = "Format on save (global)",
            get = function()
              return vim.g.autoformat ~= false
            end,
            set = function(state)
              vim.g.autoformat = state
            end,
          }):map("<leader>uf")
          Snacks.toggle({
            name = "Format on save (buffer)",
            get = function()
              return vim.b.autoformat ~= false
            end,
            set = function(state)
              vim.b.autoformat = state
            end,
          }):map("<leader>uF")
        end,
      })
    end,
  },
}
