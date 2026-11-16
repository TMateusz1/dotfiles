local sc = require("schema-companion")

return sc.setup_client(
  sc.adapters.yamlls.setup({
    sources = {
      -- apiVersion/kind → yannh schemas; CRDs → datreeio catalog (fetched from GitHub).
      sc.sources.matchers.kubernetes.setup({ version = "master" }),
      sc.sources.lsp.setup(),
      sc.sources.none.setup(),
    },
  }),
  {
    filetypes = { "yaml", "yaml.helm-values" }, -- never "helm"; helm_ls runs its own yamlls
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        keyOrdering = false,
        format = { enable = false },
        validate = true,
        hover = true,
        completion = true,
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
      },
    },
  }
)
