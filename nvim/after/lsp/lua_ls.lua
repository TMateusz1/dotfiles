-- StyLua formats.
return {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      completion = { callSnippet = "Replace" },
      hint = { enable = true, setType = false, arrayIndex = "Disable" },
      doc = { privateName = { "^_" } },
      format = { enable = false },
    },
  },
}
