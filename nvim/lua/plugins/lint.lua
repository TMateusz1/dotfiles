-- Linting for what no language server already covers.
--
-- Deliberately narrow — currently just Dockerfile. Two things are absent on
-- purpose:
--
-- * **Go.** gopls runs staticcheck plus the unusedparams/shadow/nilness
--   analysers (see lsp.lua), so golangci-lint on every write would duplicate
--   those messages and add seconds of latency on a large repo. The binary
--   is installed by Mason and run deliberately with <leader>cgl/cgL.
-- * **Python type checking.** mypy can traverse a whole project and build an
--   incremental cache, so <leader>cpm runs it deliberately and reports results
--   in Trouble instead of blocking every write. Ruff's fast LSP diagnostics
--   remain live.
--
-- See docs/nvim.md#linting.
local function python_root(path)
  local marker = vim.fs.find({ "mypy.ini", ".mypy.ini", "pyproject.toml", "setup.cfg", "setup.py", ".git" }, {
    upward = true,
    path = vim.fs.dirname(path),
    limit = 1,
  })[1]
  return marker and vim.fs.dirname(marker) or vim.fs.dirname(path)
end

local function parse_mypy(output)
  local items = {}
  for line in output:gmatch("[^\r\n]+") do
    local ok, diagnostic = pcall(vim.json.decode, line)
    if not ok then
      error("invalid mypy JSON: " .. line)
    end

    local message = diagnostic.message or "mypy finding"
    if diagnostic.code then
      message = ("%s [%s]"):format(message, diagnostic.code)
    end
    table.insert(items, {
      filename = diagnostic.file,
      lnum = math.max(diagnostic.line or 1, 1),
      col = math.max((diagnostic.column or 0) + 1, 1),
      end_lnum = diagnostic.end_line,
      end_col = diagnostic.end_column and diagnostic.end_column + 1 or nil,
      text = message,
      type = diagnostic.severity == "error" and "E" or "I",
    })
  end
  return items
end

local function run_mypy()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("mypy requires a file on disk", vim.log.levels.ERROR)
    return
  end

  local root = python_root(path)
  local executable = vim.fs.joinpath(root, ".venv", "bin", "mypy")
  if vim.fn.executable(executable) ~= 1 then
    executable = "mypy"
  end

  require("config.quickfix").run({
    name = "mypy",
    title = "mypy",
    cmd = { executable, "--output=json", "--show-error-end", "--show-absolute-path", "." },
    cwd = root,
    parse = parse_mypy,
    accepted_exit_codes = { [0] = true, [1] = true },
    save = true,
  })
end

return {
  "mfussenegger/nvim-lint",
  dependencies = { "mason-org/mason.nvim" },
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  keys = {
    {
      "<leader>cpm",
      run_mypy,
      ft = "python",
      desc = "Python: type-check project",
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
