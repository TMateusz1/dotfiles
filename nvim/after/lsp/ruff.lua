return {
  init_options = { settings = { logLevel = "error" } },
  -- ty's hover wins.
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
