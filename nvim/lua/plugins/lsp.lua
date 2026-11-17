return {
  { "b0o/SchemaStore.nvim", lazy = true },
  {
    "cenk1cenk2/schema-companion.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    -- `ft` sources its ftdetect at startup: templates -> helm, values*.yaml -> yaml.helm-values.
    "qvalentin/helm-ls.nvim",
    ft = { "helm", "yaml.helm-values" },
    opts = {
      conceal_templates = { enabled = true },
      indent_hints = { enabled = true, only_for_current_line = true },
      action_highlight = { enabled = true },
    },
    init = function()
      -- Template conceal handles wrapped lines correctly only with conceal on.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "helm",
        callback = function()
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
  },

  {
    -- Data only: provides lsp/*.lua defaults; overrides live in after/lsp/.
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp", "b0o/SchemaStore.nvim", "cenk1cenk2/schema-companion.nvim" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        root_markers = { ".git" },
      })
      vim.lsp.enable({
        "gopls",
        "vtsls",
        "eslint",
        "biome",
        "jsonls",
        "yamlls",
        "helm_ls",
        "lua_ls",
        "bashls",
        "docker_language_server",
        "ty",
        "ruff",
        "rust_analyzer",
        "taplo",
        "rumdl",
        "marksman",
      })

      -- Built-in gr* maps are covered by gr / gI / gy / <leader>c*; drop them so `gr` fires at once.
      for _, lhs in ipairs({ "grn", "grr", "gri", "grt", "grx" }) do
        pcall(vim.keymap.del, "n", lhs)
      end
      pcall(vim.keymap.del, { "n", "x" }, "gra")

      local group = vim.api.nvim_create_augroup("user_lsp", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(ev)
          local function map(lhs, rhs, desc, mode, extra)
            vim.keymap.set(
              mode or "n",
              lhs,
              rhs,
              vim.tbl_extend("force", { buffer = ev.buf, desc = desc }, extra or {})
            )
          end
          map("gd", function()
            Snacks.picker.lsp_definitions()
          end, "Definition")
          map("gD", function()
            vim.cmd.vsplit()
            vim.lsp.buf.definition()
          end, "Definition in vsplit")
          map("gr", function()
            Snacks.picker.lsp_references()
          end, "References")
          map("gI", function()
            Snacks.picker.lsp_implementations()
          end, "Implementations")
          map("gy", function()
            Snacks.picker.lsp_type_definitions()
          end, "Type definition")
          map("gK", vim.lsp.buf.signature_help, "Signature help")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cR", function()
            Snacks.rename.rename_file()
          end, "Rename file")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "LSP health")
          map("<leader>co", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" }, diagnostics = {} },
              apply = true,
            })
          end, "Organize imports")
          map("<leader>cc", vim.lsp.codelens.run, "Run codelens")
        end,
      })

      -- Organize Go imports on save (gopls/doc/vim.md).
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        pattern = "*.go",
        callback = function(ev)
          if vim.g.autoformat == false or vim.b[ev.buf].autoformat == false then
            return
          end
          local client = vim.lsp.get_clients({ bufnr = ev.buf, name = "gopls" })[1]
          if not client then
            return
          end
          -- Params for the buffer being written, not the current window (`:wa`).
          local params = {
            textDocument = { uri = vim.uri_from_bufnr(ev.buf) },
            range = {
              start = { line = 0, character = 0 },
              ["end"] = { line = vim.api.nvim_buf_line_count(ev.buf), character = 0 },
            },
            context = { only = { "source.organizeImports" }, diagnostics = {} },
          }
          local result = client:request_sync("textDocument/codeAction", params, 1000, ev.buf) or {}
          for _, action in pairs(result.result or {}) do
            if action.edit then
              vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
            elseif action.command then
              client:exec_cmd(action.command, { bufnr = ev.buf })
            end
          end
        end,
      })
    end,
  },
}
