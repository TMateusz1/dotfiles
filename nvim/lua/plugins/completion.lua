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
    -- One key, one job. <Tab> is *only* snippet navigation and <CR> is the
    -- only way to accept, because sharing <Tab> between the two collides
    -- exactly where it hurts: typing inside a snippet placeholder opens the
    -- completion menu, and a Tab meant as "next field" would take a
    -- suggestion instead. blink's `super-tab` preset calls accept() before
    -- snippet_forward, so that collision is structural rather than occasional.
    keymap = { preset = "enter" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      list = {
        selection = {
          -- Nothing is selected until <C-n>/<C-p> is pressed. This is what
          -- keeps <CR> honest: with a preselected item, Enter would accept it
          -- whenever the menu happened to be open and could never just insert
          -- a newline. The cost is one extra keystroke to take the top
          -- suggestion.
          preselect = false,
          auto_insert = true,
        },
      },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      -- Only renders once an item is actually selected, which with
      -- preselect = false means while browsing with <C-n>.
      ghost_text = { enabled = true },
    },
    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}
