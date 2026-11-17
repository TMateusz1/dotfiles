return {
  {
    "saghen/blink.cmp",
    -- A release tag gets the prebuilt fuzzy binary, verified against its .sha256.
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        accept = { auto_brackets = { enabled = true } },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
            components = {
              kind_icon = {
                text = function(ctx)
                  local icon = require("mini.icons").get("lsp", ctx.kind)
                  return icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  local _, hl = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      snippets = { preset = "default" },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
          snippets = {
            opts = { friendly_snippets = false, search_paths = { vim.fn.stdpath("config") .. "/snippets" } },
          },
        },
      },
      cmdline = {
        enabled = true,
        -- Inherit insert-mode navigation (<Up>/<Down>, <C-j>/<C-k>, <Tab>/<CR>) instead of
        -- blink's cmdline preset, which binds <Left>/<Right>, omits <Up>/<Down>, and auto-accepts on <Tab>.
        keymap = {
          preset = "inherit",
          ["<C-u>"] = false,
          ["<C-d>"] = false,
        },
        completion = {
          -- Cmdline doesn't inherit top-level `completion.list.selection`; disable both so
          -- typing a command + `<CR>` runs it instead of accepting the first completion.
          list = { selection = { preselect = false, auto_insert = false } },
          menu = { auto_show = true },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } }, "snacks.nvim", "lazy.nvim" },
    },
  },
}
