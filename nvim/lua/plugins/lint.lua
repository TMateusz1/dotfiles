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

      -- The adapter picks package vs single-file mode once, from nvim's startup cwd; pick per buffer.
      local patched = false
      local function golangci_target()
        local file = vim.api.nvim_buf_get_name(0)
        return vim.fs.root(0, roots.golangcilint) and vim.fn.fnamemodify(file, ":h") or file
      end

      local function try_lint(buf, event)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        vim.api.nvim_buf_call(buf, function()
          for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
            local linter = lint.linters[name]
            if name == "golangcilint" and not patched and type(linter) == "table" and linter.args then
              linter.args[#linter.args] = golangci_target
              patched = true
            end
            local cmd = type(linter) == "table" and linter.cmd or name
            if type(cmd) == "function" then
              cmd = cmd()
            end
            local root = roots[name] and vim.fs.root(0, roots[name])
            -- selene only where a selene.toml configures it (e.g. this repo).
            if vim.fn.executable(cmd) == 1 and (name ~= "selene" or root) then
              -- Linters that read the file from disk would report stale lines before a save.
              lint.try_lint(name, { cwd = root or nil, filter = event == "InsertLeave" and "stdin" or nil })
            end
          end
        end)
      end

      local timers = {}
      local group = vim.api.nvim_create_augroup("user_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = group,
        callback = function(ev)
          local timer = timers[ev.buf] or assert(vim.uv.new_timer())
          timers[ev.buf] = timer
          timer:start(
            100,
            0,
            vim.schedule_wrap(function()
              try_lint(ev.buf, ev.event)
            end)
          )
        end,
      })
      vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        callback = function(ev)
          if timers[ev.buf] then
            timers[ev.buf]:close()
            timers[ev.buf] = nil
          end
        end,
      })
      try_lint(vim.api.nvim_get_current_buf(), "BufReadPost")
    end,
  },
}
