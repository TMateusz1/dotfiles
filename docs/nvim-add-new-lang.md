# Add a language to Neovim

Follow these steps to add syntax highlighting, a language server, formatting,
and optional linting. The examples are templates: replace names such as
`newlang`, `server_name`, and `formatter_name` with the names from the tool's
documentation. They do not describe the languages already configured here.

## 1. Choose the tools and record their names

Choose maintained tools from trusted upstream projects. Decide what each tool
will provide: language intelligence, formatting, or extra checks. A language
server may already provide formatting and lint diagnostics, so additional
tools are optional.

Record these separately; they are not necessarily the same name:

- **Filetype:** the value Neovim assigns to the buffer.
- **Parser:** the Treesitter grammar name.
- **Server:** the configuration name in
  [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/tree/master/lsp).
- **Executable:** the command that starts the server, formatter, or linter.
- **Adapter:** the formatter/linter name supported by Conform or nvim-lint.
- **Package:** the mise backend and package that supplies the executable.

Check the server's documentation for supported filetypes, required command
arguments, and project root markers. Check whether it requires a runtime or
compiler as well.

## 2. Install and pin the executables

Add shared tools under `[tools]` in [mise/config.toml](../mise/config.toml).
Use explicit versions and supported backends; keep asdf and vfox disabled.
Declare runtime dependencies when the backend needs them.

For example, an npm package entry has this shape:

```toml
"npm:package-name" = { version = "<exact-version>", depends = ["node"] }
```

Use the package and version you actually selected. Add its required runtime
if necessary. For tools used only in one project, declare them in that
project's mise config instead. Neovim must still be launched with those
executables on its `PATH`.

From this repository's root, refresh the staged global lockfile and install:

```sh
MISE_GLOBAL_CONFIG_FILE="$PWD/mise/config.toml" mise lock --global
MISE_GLOBAL_CONFIG_FILE="$PWD/mise/config.toml" mise install
```

The override selects this repository's global config rather than the machine's
separate global config. Keep `mise/config.toml` and `mise/mise.lock` together
when recording the change. If changing a platform overlay, also select that
environment and refresh its lockfile; see [mise conventions](./mise.md).

Confirm the command resolves in the shell used to launch Neovim:

```sh
command -v server-binary
```

Use the tool's documented version command to verify the installed version.
Do not add Mason or executable downloads to Neovim's configuration.

## 3. Check filetype detection

Open a representative file and run:

```vim
:set filetype?
```

If detection is correct, no change is needed. Otherwise, add a rule to
[filetypes.lua](../nvim/lua/config/filetypes.lua), for example:

```lua
vim.filetype.add({
  extension = {
    newext = "newlang",
  },
})
```

Use filename or path rules if an extension alone is ambiguous. Reopen the
file and check again. The detected filetype must match the server's supported
filetypes and the keys used in formatter/linter configuration.

## 4. Enable the language server

In [lsp.lua](../nvim/lua/plugins/lsp.lua), add the server's nvim-lspconfig name
to the existing `vim.lsp.enable({ ... })` list:

```lua
"server_name",
```

Use the supplied defaults first. If the server needs settings or different
command arguments, add an override inside the existing configuration function,
before the enable list:

```lua
vim.lsp.config("server_name", {
  cmd = { "server-binary", "--stdio" },
  settings = {
    -- Use the exact settings documented by this server.
  },
})
```

Only include `--stdio` if that server requires it. Override root detection
only when the supplied definition does not match the project layout. If
nvim-lspconfig has no definition, create a native definition with the command,
filetypes, and root markers specified by the server documentation.

Use native `vim.lsp.config()` and `vim.lsp.enable()`, following
[nvim-lspconfig's quickstart](https://github.com/neovim/nvim-lspconfig#quickstart).
The existing `LspAttach` handler supplies navigation and code-action mappings;
ordinary language additions do not need their own copies.

## 5. Add syntax highlighting

Find the grammar in Treesitter's
[supported languages](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md).
Add its parser name to the existing `parsers` list in
[treesitter.lua](../nvim/lua/plugins/treesitter.lua):

```lua
"parser_name",
```

The existing configuration installs declared parsers and starts highlighting.
Restart Neovim and allow compilation to finish. Parser compilation requires
the mise-managed `tree-sitter` CLI and a C compiler.

If a custom filetype is not mapped to its parser, register the alias before
highlighting starts:

```lua
vim.treesitter.language.register("parser_name", "newlang")
```

Do not add a second parser list or legacy `ensure_installed` configuration.
This repository uses the Treesitter `main` API; see its
[setup documentation](https://github.com/nvim-treesitter/nvim-treesitter#setup).

## 6. Choose formatting

If the language server supplies suitable formatting, the existing Conform LSP
fallback can use it without another formatter entry.

For a separate formatter, choose an adapter from
[Conform's formatter list](https://github.com/stevearc/conform.nvim#formatters)
and add a filetype entry under `formatters_by_ft` in
[conform.lua](../nvim/lua/plugins/conform.lua):

```lua
newlang = { "formatter_name" },
```

The formatter executable must be installed in step 2. Prefer its project
configuration file for style rules. Override the adapter's command, arguments,
or working directory only if the defaults do not handle the project correctly.

Multiple listed formatters run sequentially. For alternatives where only the
first available formatter should run, use `stop_after_first = true`.
With `lsp_format = "fallback"`, LSP formatting runs when no external formatter
is available; it is not a retry after an external formatter fails.

Restart Neovim, open a file, and run `:ConformInfo`. Test both manual formatting
with `<leader>cf` and formatting on save. `<leader>` is Space.

## 7. Add optional linting

First check which diagnostics the language server already reports. Add a
separate linter when it covers useful additional checks; avoid reporting the
same problem twice.

For a fast file-oriented linter, select a supported
[nvim-lint adapter](https://github.com/mfussenegger/nvim-lint#available-linters).
Add an entry to the existing `lint.linters_by_ft` table in
[lint.lua](../nvim/lua/plugins/lint.lua):

```lua
newlang = { "linter_name" },
```

Install its executable in step 2. The existing autocmds run configured linters
on opening and saving a file. Use the linter's project configuration for rules
and exclusions. If it has no adapter, check nvim-lint's custom-linter API before
adding integration code; its output must be parsed into diagnostics.

For a slower project-wide check, add an explicit command using the existing
[quickfix runner](../nvim/lua/config/quickfix.lua). Configure the executable,
project root, accepted exit codes, and an output parser with filenames and
positions. Prefer structured output when the tool provides it. These results
can be displayed in Trouble and searched through the existing quickfix picker.

Give any new mapping an accurate `desc`. If it introduces a leader namespace,
update the group declarations in
[which-key.lua](../nvim/lua/plugins/which-key.lua). Reuse the established code
action namespace and avoid duplicating generic navigation mappings.

## 8. Verify in a real project

Restart Neovim from a shell where mise is active. Open a representative project
with the root markers expected by the server and check:

```vim
:set filetype?
:lua print(vim.fn.executable("server-binary"))
:LspInfo
:ConformInfo
:checkhealth vim.lsp
```

The executable check should print `1`. Verify these behaviors:

- The expected server attaches to the buffer with the correct project root.
- Completion, hover, definition navigation, and rename work where supported.
- A deliberate error produces an understandable diagnostic without duplicates.
- Formatting works manually and on save, using the project's style rules.
- The additional linter reports and clears findings after a fix and save.
- Treesitter highlights the file without parser errors (`:InspectTree`).
- Any explicit project check reports findings with working file navigation.

If attachment fails, check the executable, filetype, command arguments, and
project root first. Use `:LspLog` for server errors. If formatting fails,
`:ConformInfo` shows availability and the formatter log location.

## 9. Document and review the change

Update [nvim.md](./nvim.md) with the new language support and any special setup
requirements. If adding shared language tooling, update [langs.md](./langs.md)
as appropriate. Include required project configuration and any new shortcuts.

Run the established Lua and Markdown format/lint tools for changed files.
Review the config and lockfile diffs for unrelated changes or sensitive data.
Leave staging and committing to the user.
