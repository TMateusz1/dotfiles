local sc = require("schema-companion")

-- helm-ls starts its own yaml-language-server for the YAML parts of templates.
return sc.setup_client(
  sc.adapters.helmls.setup({
    sources = { sc.sources.matchers.kubernetes.setup({ version = "master" }) },
  }),
  {
    settings = {
      ["helm-ls"] = {
        yamlls = {
          enabled = true,
          path = "yaml-language-server",
          config = { schemas = { kubernetes = "templates/**" }, completion = true, hover = true },
        },
      },
    },
  }
)
