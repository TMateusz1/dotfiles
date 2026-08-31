-- Language servers. No mason.nvim: every binary comes from the global mise
-- config and is expected on $PATH; Neovim only configures clients. See
-- docs/nvim.md#lsp.
--
-- Neovim 0.11+ reads `lsp/<name>.lua` from the runtimepath, and nvim-lspconfig
-- is on that path purely to supply those definitions. `vim.lsp.enable()` turns
-- them on; `vim.lsp.config()` layers this repo's overrides on top. There is no
-- `require("lspconfig").setup()` anywhere — that API is the old one.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- Pure Lua catalogue of JSON/YAML schemas; no binary, no download at runtime.
    { "b0o/SchemaStore.nvim", version = "*" },
  },
  config = function()
    -- Diagnostics -----------------------------------------------------------
    vim.diagnostic.config({
      severity_sort = true,
      underline = true,
      update_in_insert = false,
      -- Virtual *lines* rather than virtual text: gopls messages routinely run
      -- past the window width, and inline text truncates them. Limiting to the
      -- cursor's line keeps the buffer from jumping around while typing.
      virtual_text = false,
      virtual_lines = { current_line = true },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      },
    })

    -- Per-server overrides --------------------------------------------------
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          gofumpt = true,
          staticcheck = true,
          usePlaceholders = true,
          completeUnimported = true,
          -- Operator repos vendor large dependency trees; indexing them makes
          -- gopls slow to start and pollutes completion with copies.
          directoryFilters = { "-vendor", "-node_modules", "-.git" },
          analyses = {
            unusedparams = true,
            unusedwrite = true,
            shadow = true,
            nilness = true,
            useany = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          codelenses = { generate = true, test = true, tidy = true, upgrade_dependency = true },
        },
      },
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          -- lazydev.nvim supplies the Neovim API library paths; anything set
          -- here would fight it.
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          hint = { enable = true },
        },
      },
    })

    vim.lsp.config("jsonls", {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" }, -- SchemaStore.nvim replaces it
          schemas = require("schemastore").yaml.schemas(),
          validate = true,
          keyOrdering = false, -- alphabetical key order is not a real rule
        },
      },
    })

    vim.lsp.enable({
      "gopls",
      "lua_ls",
      "jsonls",
      "yamlls",
      "helm_ls",
      "ruff",
      "rust_analyzer",
    })

    -- Buffer-local keymaps --------------------------------------------------
    -- Neovim 0.12 already maps grn (rename), gra (code action), grr
    -- (references), gri (implementation), grt (type definition), gO (document
    -- symbols), ]d/[d (diagnostics) and i_<C-s> (signature help), and binds K
    -- to hover on attach. Only what it does *not* provide is added here.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("dotfiles.lsp.attach", { clear = true }),
      callback = function(ev)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
        end

        -- fzf-lua rather than the built-in: multiple definitions land in a
        -- picker instead of the quickfix list.
        map("n", "gd", "<cmd>FzfLua lsp_definitions<cr>", "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")

        map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
        map("n", "<leader>cf", function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end, "Format buffer")
        map("n", "<leader>cr", "<cmd>LspRestart<cr>", "Restart LSP")
        map("n", "<leader>ci", "<cmd>LspInfo<cr>", "LSP info")

        -- Inlay hints are configured for gopls and lua_ls above; this makes
        -- them switchable rather than permanent visual noise.
        if vim.lsp.inlay_hint then
          map("n", "<leader>uh", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
            vim.notify("Inlay hints " .. (enabled and "off" or "on"))
          end, "Toggle inlay hints")
        end
      end,
    })
  end,
}
