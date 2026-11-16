return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      -- Everything else is linted by its LSP.
      lint.linters_by_ft = {
        go = { "golangcilint" },
        dockerfile = { "hadolint" },
        lua = { "selene" },
      }

      -- Run from the project root, not nvim's cwd: golangci-lint needs its go.mod (else every
      -- import fails to resolve) and selene reads selene.toml and its std from the cwd.
      local roots = { golangcilint = { "go.work", "go.mod" }, selene = { "selene.toml" } }

      local function try_lint()
        for _, name in ipairs(lint._resolve_linter_by_ft(vim.bo.filetype)) do
          local linter = lint.linters[name]
          local cmd = type(linter) == "table" and linter.cmd or name
          if type(cmd) == "function" then
            cmd = cmd()
          end
          local root = roots[name] and vim.fs.root(0, roots[name])
          -- selene only where a selene.toml configures it (e.g. this repo).
          if vim.fn.executable(cmd) == 1 and (name ~= "selene" or root) then
            lint.try_lint(name, { cwd = root or nil })
          end
        end
      end

      local timer = assert(vim.uv.new_timer())
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
        callback = function()
          timer:start(100, 0, vim.schedule_wrap(try_lint))
        end,
      })
      try_lint()
    end,
  },
}
