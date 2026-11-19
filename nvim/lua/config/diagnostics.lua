local sev = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  -- tiny-inline-diagnostic.nvim renders current-line virtual text.
  virtual_text = false,
  virtual_lines = false,
  float = { border = "rounded", source = "if_many" },
  signs = { text = { [sev.ERROR] = " ", [sev.WARN] = " ", [sev.INFO] = " ", [sev.HINT] = "󰌵 " } },
})
