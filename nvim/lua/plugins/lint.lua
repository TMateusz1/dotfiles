-- Linting for what no language server already covers.
--
-- Deliberately narrow — currently just Dockerfile. Two things are absent on
-- purpose:
--
-- * **Go.** gopls runs staticcheck plus the unusedparams/shadow/nilness
--   analysers (see lsp.lua), so golangci-lint on every write would duplicate
--   those messages and add seconds of latency on a large repo. The binary
--   stays in mise and is run deliberately — `golangci-lint run`, or in CI.
-- * **Kubernetes manifests.** kubeconform is installed and is the right tool,
--   but it is not wired to run on save. <leader>ckl validates the current file
--   deliberately and publishes the result to quickfix.
--
-- See docs/nvim.md#linting.
local function parse_kubeconform(output)
  if vim.trim(output) == "" then
    return {}
  end

  local decoded = vim.json.decode(output)
  local items = {}
  for _, resource in ipairs(decoded.resources or {}) do
    local status = (resource.status or ""):lower()
    if status ~= "valid" and status ~= "statusvalid" then
      local message = resource.msg or resource.status or "validation failed"
      local identity = table.concat(
        vim.tbl_filter(function(value)
          return value and value ~= ""
        end, { resource.kind, resource.version }),
        " "
      )
      table.insert(items, {
        filename = resource.filename,
        lnum = 1,
        col = 1,
        text = identity ~= "" and (identity .. ": " .. message) or message,
        type = status:find("invalid", 1, true) and "E" or "W",
      })
    end
  end
  return items
end

local function run_kubeconform()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Kubeconform requires a file on disk", vim.log.levels.ERROR)
    return
  end

  require("config.quickfix").run({
    name = "kubeconform",
    title = "kubeconform",
    cmd = { "kubeconform", "-output", "json", path },
    cwd = vim.fs.dirname(path),
    parse = parse_kubeconform,
    accepted_exit_codes = { [0] = true, [1] = true },
    save = true,
  })
end

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  keys = {
    {
      "<leader>ckl",
      run_kubeconform,
      ft = "yaml",
      desc = "Kubernetes: validate file",
    },
  },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      dockerfile = { "hadolint" },
    }

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("dotfiles.lint", { clear = true }),
      callback = function(ev)
        if ev.buf == vim.api.nvim_get_current_buf() then
          lint.try_lint()
        end
      end,
    })

    -- This plugin lazy-loads *on* BufReadPost, so by the time the autocommand
    -- above exists, the event that loaded it has already been dispatched and
    -- the very first file opened would never be linted. Lint it explicitly.
    lint.try_lint()
  end,
}
