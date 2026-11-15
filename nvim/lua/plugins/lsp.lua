return {
  { "b0o/SchemaStore.nvim", lazy = true },
  {
    "cenk1cenk2/schema-companion.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
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
      })

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
          end, "References", "n", { nowait = true })
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
        end,
      })

      -- Organize Go imports on save (gopls/doc/vim.md).
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        pattern = "*.go",
        callback = function(ev)
          local client = vim.lsp.get_clients({ bufnr = ev.buf, name = "gopls" })[1]
          if not client then
            return
          end
          local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
          ---@diagnostic disable-next-line: inject-field
          params.context = { only = { "source.organizeImports" } }
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
