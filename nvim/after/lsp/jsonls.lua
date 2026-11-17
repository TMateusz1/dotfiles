-- Conform formats JSON (Biome/Prettier).
return {
  init_options = { provideFormatter = false },
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}
