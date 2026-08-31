return {
  "saghen/blink.cmp",
  version = "*",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },
  -- blink ships a Rust fuzzy matcher and by default *downloads* a prebuilt
  -- library from GitHub, which this repo does not allow. Building it here from
  -- source instead uses the Rust toolchain already pinned in the global mise
  -- config — the same carve-out, for the same reason, as nvim-treesitter
  -- compiling its parsers. See AGENTS.md and docs/nvim.md#completion.
  build = "cargo build --release",
  opts = {
    -- `prefer_rust`, not `rust`: if the build ever fails on a fresh machine,
    -- completion degrades to the Lua matcher instead of breaking the config.
    fuzzy = { implementation = "prefer_rust" },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    snippets = { preset = "default" }, -- Neovim's native vim.snippet
    -- `super-tab`, not blink's `default`: in the default preset the accept key
    -- is <C-y> and <Tab> only jumps between placeholders of an *already
    -- expanded* snippet, which reads as "snippets don't work". Here <Tab>
    -- accepts the selected item, then jumps through the snippet's fields, and
    -- falls back to a literal tab when no menu is open.
    keymap = { preset = "super-tab" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      ghost_text = { enabled = true },
    },
    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}
