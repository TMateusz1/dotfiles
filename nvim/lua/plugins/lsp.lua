-- Language servers. No mason.nvim: every binary comes from the global mise
-- config and is expected on $PATH; Neovim only configures clients. See
-- docs/nvim.md#lsp.
--
-- Neovim 0.11+ reads `lsp/<name>.lua` from the runtimepath, and nvim-lspconfig
-- is on that path purely to supply those definitions. `vim.lsp.enable()` turns
-- them on; `vim.lsp.config()` layers this repo's overrides on top. There is no
-- `require("lspconfig").setup()` anywhere — that API is the old one.
local function project_venv(root)
  for _, name in ipairs({ ".venv", "venv" }) do
    local path = vim.fs.joinpath(root, name)
    if vim.uv.fs_stat(path) then
      return path
    end
  end
end

local function start_robotcode(dispatchers, config)
  local root = config.root_dir or vim.uv.cwd()
  local venv = project_venv(root)
  local executable = "robotcode"
  local env

  if venv then
    local local_executable = vim.fs.joinpath(venv, "bin", "robotcode")
    if vim.fn.executable(local_executable) == 1 then
      executable = local_executable
    else
      -- The global server can still resolve libraries installed in the
      -- project's conventional virtualenv even when RobotCode itself is not
      -- installed there.
      local site_packages = vim.fs.find("site-packages", {
        path = venv,
        type = "directory",
        limit = 1,
      })[1]
      if site_packages then
        local pythonpath = site_packages
        if vim.env.PYTHONPATH then
          pythonpath = pythonpath .. ":" .. vim.env.PYTHONPATH
        end
        env = { PYTHONPATH = pythonpath }
      end
    end
  end

  return vim.lsp.rpc.start({ executable, "language-server" }, dispatchers, {
    cwd = root,
    env = env,
  })
end

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
          -- Operator repos vendor large dependency trees; indexing them makes
          -- gopls slow to start and pollutes completion with copies.
          directoryFilters = { "-**/vendor", "-**/node_modules", "-**/.git" },
          analyses = {
            unusedparams = true,
            unusedwrite = true,
            shadow = true,
            nilness = true,
            any = true,
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
          schemas = require("schemastore").yaml.schemas({
            extra = {
              {
                name = "Kubernetes",
                description = "Kubernetes manifests in conventional project paths",
                url = "kubernetes",
                fileMatch = {
                  "k8s/**/*.yaml",
                  "k8s/**/*.yml",
                  "manifests/**/*.yaml",
                  "manifests/**/*.yml",
                  "deploy/**/*.yaml",
                  "deploy/**/*.yml",
                  "**/*.k8s.yaml",
                  "**/*.k8s.yml",
                },
              },
            },
          }),
          validate = true,
          keyOrdering = false, -- alphabetical key order is not a real rule
        },
      },
    })

    vim.lsp.config("helm_ls", {
      settings = {
        ["helm-ls"] = {
          helmLint = { enabled = true },
          yamlls = {
            enabled = true,
            path = "yaml-language-server",
          },
        },
      },
    })

    vim.lsp.config("basedpyright", {
      -- basedpyright remains the Python language-service engine, but mypy is
      -- the authoritative type checker and Ruff owns lint diagnostics.
      settings = {
        basedpyright = {
          analysis = { typeCheckingMode = "off" },
        },
      },
      handlers = {
        ["textDocument/publishDiagnostics"] = function() end,
      },
      on_init = function(client)
        client.server_capabilities.diagnosticProvider = nil
      end,
    })

    vim.lsp.config("robotcode", {
      -- Prefer a conventional project-local installation without requiring
      -- shell activation, then fall back to the first `robotcode` on PATH
      -- (normally the globally pinned mise binary).
      cmd = start_robotcode,
    })

    vim.lsp.enable({
      "gopls",
      "lua_ls",
      "jsonls",
      "yamlls",
      "helm_ls",
      "ruff",
      "basedpyright",
      "robotcode",
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
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.name == "ruff" then
          -- Ruff intentionally complements basedpyright. Let the type-aware
          -- server own hover instead of presenting two competing responses.
          client.server_capabilities.hoverProvider = false
        end

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
