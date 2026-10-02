# Languages

Language runtimes and compilers live in the **global mise config**; Neovim's
LSPs, formatters, linters and editing utilities live in **Mason**. See
[mise.md](./mise.md#maintaining-editor-tools) for provisioning and updates.

## Rust

Mise pins Rust (`rustc` and `cargo`), used by projects, `cargo:eza`, and the
locally compiled blink.cmp fuzzy matcher. Mason installs `rust-analyzer` and
prepends its bin directory to Neovim's PATH, ahead of rustup's optional copy.

## Go

Mise pins Go. Neotest drives `go test` directly and needs no additional runner
binary. Mason installs
`gopls`, `goimports`, `gofumpt`, `golangci-lint`, `gomodifytags` and `impl`.
Go must be available when Mason builds Go packages.

Conform runs goimports followed by gofumpt. gopls supplies completion,
navigation, staticcheck and extra analyses. `<leader>cgl` runs golangci-lint
for the project; `<leader>cgL` adds fixes. Results appear in Trouble.
Golangci-lint reads each project's own configuration; this repo has no global
Go lint policy. Gopher's own installer is disabled because Mason supplies its
struct-tag editor and interface generator.

Go's `GOENV` path on macOS is `~/Library/Application Support/go/env`, independent
of `XDG_CONFIG_HOME`; no file is provisioned there.

## Protocol Buffers

Mason installs [Buf](https://buf.build/docs/cli/). `buf lsp serve` supplies
nvim-lspconfig's `buf_ls`: completion, navigation, live lint diagnostics and
formatting. Conform uses LSP fallback. Buf reads the project's `buf.yaml`;
this dotfiles repository has no Buf module or repo-level Buf checks.

## Python and Robot Framework

Mise pins Python, Node and uv. Mason installs basedpyright, Ruff, mypy and
RobotCode. Basedpyright owns completion, navigation and hover with diagnostics
disabled; Ruff owns live lint, import organization and formatting. `<leader>cpm`
runs mypy asynchronously from the project root and sends JSON findings to
Trouble. `.venv/bin/mypy` takes precedence over Mason's mypy.

Mason installs RobotCode with its `all` extra into an isolated Python environment.
Robot Framework and Robocop are dependencies inside that environment; they
are not separately installed by mise or exposed on the shell PATH. Projects
should declare their actual Robot test libraries and dependencies.
RobotCode prefers `.venv/bin/robotcode` or `venv/bin/robotcode`, then falls back
to Mason. If a conventional virtualenv contains libraries but no RobotCode,
its `site-packages` is passed to the server through `PYTHONPATH`.

Both `.robot` and `.resource` use the `robot` filetype, a reviewed upstream
Treesitter parser revision and Catppuccin semantic token highlights. Run
`:TSUpdate robot` after changing the parser pin.

## Kotlin

Mason pins the official [JetBrains Kotlin LSP](https://github.com/Kotlin/kotlin-lsp)
as `kotlin-lsp/v263.4702.0`. It is based on IntelliJ IDEA and launches as
`intellij-server --stdio`; Neovim enables nvim-lspconfig's `kotlin_lsp` definition
for `.kt` and `.kts` files in Gradle, Maven or `workspace.json` projects.
The distribution bundles its Java runtime; project build JDKs and Gradle/Maven
remain project dependencies. Conform uses the server's formatting fallback.

## Configuration languages and checks

Mason supplies LuaLS, JSON LSP, YAML LSP and helm-ls, plus StyLua, yamlfmt,
Taplo, jq, shfmt and hadolint. Mise retains Helm for helm-ls chart linting,
and jq for shell use. Repo-local mise retains StyLua, Taplo and yamlfmt for hk.

Neovim automatically runs hadolint on Dockerfiles. Kubernetes manifests use
yamlls schema diagnostics. See [nvim.md](./nvim.md) for mappings,
schemas and formatting. Mason's tools are available within Neovim, including
its terminals, but are not added to the shell PATH outside the editor.
