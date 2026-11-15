local sev = vim.diagnostic.severity

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  -- Inline only on the current line, without the layout shifts of virtual_lines.
  virtual_text = { current_line = true, spacing = 2, source = "if_many" },
  virtual_lines = false,
  float = { border = "rounded", source = "if_many" },
  signs = { text = { [sev.ERROR] = " ", [sev.WARN] = " ", [sev.INFO] = " ", [sev.HINT] = "󰌵 " } },
})
