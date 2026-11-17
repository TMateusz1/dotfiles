-- Follow the project: its own tool config wins, then a Prettier config, then our fallback.
local function project(own, own_configs, fallback)
  return function(buf)
    if vim.fs.root(buf, own_configs) then
      return own
    end
    -- `require_cwd` makes Prettier available only when the project configures it.
    if require("conform").get_formatter_info("prettier", buf).available then
      return { "prettier" }
    end
    return fallback or own
  end
end

-- biome-check also applies lint fixes, so only where the project opted into Biome.
local web = project({ "biome-check" }, { "biome.json", "biome.jsonc" }, { "biome" })
local yamlfmt_configs = { ".yamlfmt", ".yamlfmt.yml", ".yamlfmt.yaml", "yamlfmt.yml", "yamlfmt.yaml" }
local yaml = project({ "yamlfmt" }, yamlfmt_configs)
local markdown = project({ "rumdl" }, { ".rumdl.toml", "rumdl.toml" })

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
        yaml = yaml,
        markdown = markdown,
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
        -- go, rust, dockerfile: LSP fallback (gopls+gofumpt, rustfmt)
        -- helm: intentionally not formatted (templates break)
      },
      formatters = {
        prettier = {
          require_cwd = true, -- only with a Prettier config in the project
          -- The pinned conform misses TypeScript config files.
          cwd = function(self, ctx)
            return require("conform.formatters.prettier").cwd(self, ctx)
              or vim.fs.root(ctx.dirname, {
                "prettier.config.ts",
                "prettier.config.cts",
                "prettier.config.mts",
                ".prettierrc.ts",
                ".prettierrc.cts",
                ".prettierrc.mts",
              })
          end,
        },
        -- Without an .editorconfig: 2-space indent, indented case branches. With one, shfmt reads it.
        shfmt = {
          prepend_args = function(_, ctx)
            if vim.fs.find(".editorconfig", { path = ctx.dirname, upward = true })[1] then
              return {}
            end
            return { "-i", "2", "-ci" }
          end,
        },
        -- yamlfmt finds its config from the cwd; run it where the buffer's config lives.
        yamlfmt = {
          cwd = function(_, ctx)
            return vim.fs.root(ctx.dirname, yamlfmt_configs)
          end,
        },
        -- Not built into the pinned conform; rumdl exits 1 when unfixable issues remain.
        rumdl = {
          command = "rumdl",
          args = { "fmt", "--silent", "--stdin-filename", "$FILENAME", "-" },
          stdin = true,
          exit_codes = { 0, 1 },
        },
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
