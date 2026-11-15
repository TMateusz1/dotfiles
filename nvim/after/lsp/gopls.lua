-- Formatting (gofumpt) goes through conform's LSP fallback.
return {
  settings = {
    gopls = {
      gofumpt = true,
      usePlaceholders = false,
      completeUnimported = true,
      staticcheck = true,
      semanticTokens = true,
      directoryFilters = { "-.git", "-node_modules", "-.vscode", "-.idea" },
      analyses = { unusedparams = true, unusedwrite = true, nilness = true, shadow = true },
      codelenses = { generate = true, test = true, tidy = true, upgrade_dependency = true, vendor = true },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
