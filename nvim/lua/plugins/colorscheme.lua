return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- load before other plugins that may reference its highlight groups
  opts = {
    flavour = "mocha",
    -- RobotCode publishes a rich set of Robot Framework-specific semantic
    -- token types. Neovim creates language-scoped highlight groups for them,
    -- but a colorscheme cannot style non-standard LSP types unless it knows
    -- their names. Link them to Catppuccin's existing treesitter palette so
    -- semantic and syntactic highlighting remain visually consistent.
    custom_highlights = function(colors)
      return {
        YankHighlight = { bg = colors.surface1 },
        ["@lsp.type.settingImport.robot"] = { link = "@keyword.import" },
        ["@lsp.type.setting.robot"] = { link = "@keyword" },
        ["@lsp.type.header.robot"] = { link = "@markup.heading" },
        ["@lsp.type.headerSettings.robot"] = { link = "@markup.heading" },
        ["@lsp.type.headerVariable.robot"] = { link = "@markup.heading" },
        ["@lsp.type.headerTestcase.robot"] = { link = "@markup.heading" },
        ["@lsp.type.headerTask.robot"] = { link = "@markup.heading" },
        ["@lsp.type.headerComment.robot"] = { link = "@markup.heading" },
        ["@lsp.type.headerKeyword.robot"] = { link = "@markup.heading" },
        ["@lsp.type.testcaseName.robot"] = { link = "@function" },
        ["@lsp.type.keywordName.robot"] = { link = "@function" },
        ["@lsp.type.controlFlow.robot"] = { link = "@keyword" },
        ["@lsp.type.argument.robot"] = { link = "@string" },
        ["@lsp.type.variable.robot"] = { link = "@variable" },
        ["@lsp.type.keywordCall.robot"] = { link = "@function.call" },
        ["@lsp.type.keywordCallInner.robot"] = { link = "@function.call" },
        ["@lsp.type.bddPrefix.robot"] = { link = "@keyword" },
        ["@lsp.type.nameCall.robot"] = { link = "@function.call" },
        ["@lsp.type.continuation.robot"] = { link = "@punctuation.delimiter" },
        ["@lsp.type.forSeparator.robot"] = { link = "@keyword.repeat" },
        ["@lsp.type.variableBegin.robot"] = { link = "@punctuation.bracket" },
        ["@lsp.type.variableEnd.robot"] = { link = "@punctuation.bracket" },
        ["@lsp.type.expressionBegin.robot"] = { link = "@punctuation.bracket" },
        ["@lsp.type.expressionEnd.robot"] = { link = "@punctuation.bracket" },
        ["@lsp.type.variableExpression.robot"] = { link = "@string.special" },
        ["@lsp.type.escape.robot"] = { link = "@string.escape" },
        ["@lsp.type.namespace.robot"] = { link = "@module" },
        ["@lsp.type.error.robot"] = { link = "DiagnosticError" },
        ["@lsp.type.config.robot"] = { link = "@keyword.directive" },
        ["@lsp.type.namedArgument.robot"] = { link = "@variable.parameter" },
        ["@lsp.type.var.robot"] = { link = "@keyword" },
        ["@lsp.type.documentation.robot"] = { link = "@string.documentation" },
        ["@lsp.typemod.namespace.builtin.robot"] = { link = "@module" },
        ["@lsp.typemod.keywordCall.builtin.robot"] = { link = "@function.builtin" },
        ["@lsp.typemod.keywordCallInner.builtin.robot"] = { link = "@function.builtin" },
      }
    end,
    integrations = {
      diffview = true,
      gitsigns = true,
      indent_blankline = {
        enabled = true,
        scope_color = "lavender",
      },
      lsp_trouble = true,
      mini = { enabled = true },
      neotree = true,
      which_key = true,
    },
  },
  -- `config` (not `init`): lazy.nvim runs `init` *before* the plugin loads, so
  -- setting the colorscheme there applies it before `opts` ever reaches
  -- catppuccin.setup() — silently discarding every option here.
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
