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

      local function try_lint()
        local names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          local cmd = type(linter) == "table" and linter.cmd or name
          if type(cmd) == "function" then
            cmd = cmd()
          end
          if vim.fn.executable(cmd) == 0 then
            return false
          end
          -- selene only where a selene.toml configures it (e.g. this repo).
          return name ~= "selene" or vim.fs.root(0, "selene.toml") ~= nil
        end, lint._resolve_linter_by_ft(vim.bo.filetype))
        if #names > 0 then
          lint.try_lint(names)
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
