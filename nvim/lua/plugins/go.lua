-- Go helpers that gopls does not provide: struct tags, interface stubs and
-- deliberate project-wide golangci-lint runs.
-- The binaries (gomodifytags, impl) come from the global mise config, so
-- gopher's own installer is switched off — see docs/nvim.md#go.
local function go_root()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil
  end

  for _, marker in ipairs({ "go.work", "go.mod" }) do
    local match = vim.fs.find(marker, {
      upward = true,
      type = "file",
      path = vim.fs.dirname(path),
      limit = 1,
    })[1]
    if match then
      return vim.fs.dirname(match)
    end
  end
end

local function parse_golangci(output)
  if vim.trim(output) == "" then
    return {}
  end

  local decoded = vim.json.decode(output)
  local items = {}
  local types = { error = "E", warning = "W", refactor = "I", convention = "I" }

  for _, issue in ipairs(decoded.Issues or {}) do
    local position = issue.Pos or {}
    table.insert(items, {
      filename = position.Filename,
      lnum = math.max(position.Line or 1, 1),
      col = math.max(position.Column or 1, 1),
      text = ("%s [%s]"):format(issue.Text or "golangci-lint finding", issue.FromLinter or "unknown"),
      type = types[issue.Severity] or "W",
    })
  end

  return items
end

local function run_golangci(fix)
  local root = go_root()
  if not root then
    vim.notify("No go.work or go.mod found for golangci-lint", vim.log.levels.ERROR)
    return
  end

  local cmd = {
    "golangci-lint",
    "run",
    "--output.json.path=stdout",
    "--output.text.path=",
    "--output.tab.path=",
    "--output.html.path=",
    "--output.checkstyle.path=",
    "--output.code-climate.path=",
    "--output.junit-xml.path=",
    "--output.teamcity.path=",
    "--output.sarif.path=",
    "--issues-exit-code=0",
    "--show-stats=false",
    "--path-mode=abs",
  }
  if fix then
    table.insert(cmd, "--fix")
  end

  require("config.quickfix").run({
    name = "golangci-lint",
    title = fix and "golangci-lint --fix" or "golangci-lint",
    cmd = cmd,
    cwd = root,
    parse = parse_golangci,
    save = true,
    on_complete = fix and function()
      vim.cmd("checktime")
    end or nil,
  })
end

local function implement_interface()
  require("config.go_impl").pick()
end

return {
  "olexsmir/gopher.nvim",
  ft = "go",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    installation = false,
    commands = {
      go = "go",
      gomodifytags = "gomodifytags",
      impl = "impl",
    },
  },
  config = function(_, opts)
    require("gopher").setup(opts)

    -- Gopher's bare :GoImpl only reports a missing-arguments error. Make it
    -- use the picker while preserving the command's explicit-argument form.
    vim.api.nvim_del_user_command("GoImpl")
    vim.api.nvim_create_user_command("GoImpl", function(args)
      if #args.fargs == 0 then
        implement_interface()
      else
        require("gopher").impl(unpack(args.fargs))
      end
    end, { nargs = "*", desc = "Go: implement interface" })
  end,
  keys = {
    {
      "<leader>cgl",
      function()
        run_golangci(false)
      end,
      ft = "go",
      desc = "Go: lint project",
    },
    {
      "<leader>cgL",
      function()
        run_golangci(true)
      end,
      ft = "go",
      desc = "Go: lint project with fixes",
    },
    { "<leader>cta", "<cmd>GoTagAdd json<cr>", ft = "go", desc = "Go: add json tags" },
    { "<leader>cty", "<cmd>GoTagAdd yaml<cr>", ft = "go", desc = "Go: add yaml tags" },
    { "<leader>ctr", "<cmd>GoTagRm<cr>", ft = "go", desc = "Go: remove tags" },
    { "gi", implement_interface, ft = "go", desc = "Go: implement interface" },
    { "<leader>cI", implement_interface, ft = "go", desc = "Go: implement interface" },
    { "<leader>ce", "<cmd>GoIfErr<cr>", ft = "go", desc = "Go: expand if err" },
  },
}
