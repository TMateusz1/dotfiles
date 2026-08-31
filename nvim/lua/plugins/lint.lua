-- Linting for what no language server already covers.
--
-- Deliberately narrow. Go is absent: gopls runs staticcheck plus the
-- unusedparams/shadow/nilness analysers (see lsp.lua), so golangci-lint on
-- every write would duplicate those messages and add seconds of latency on a
-- large repo. The binary stays in mise and is run on purpose — `golangci-lint
-- run`, or in CI. See docs/nvim.md#linting.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      dockerfile = { "hadolint" },
      -- Not plain `yaml`: kubeconform rejects any document without a k8s
      -- apiVersion/kind, which is most YAML. The autocommand below narrows it
      -- to buffers that actually look like manifests.
      helm = {},
    }

    local function looks_like_k8s(bufnr)
      for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 40, false)) do
        if line:match("^apiVersion:%s*%S") then
          return true
        end
      end
      return false
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("dotfiles.lint", { clear = true }),
      callback = function(ev)
        if vim.bo[ev.buf].filetype == "yaml" then
          if looks_like_k8s(ev.buf) then
            lint.try_lint("kubeconform")
          end
          return
        end
        lint.try_lint()
      end,
    })
  end,
}
