# Languages

Language toolchains configured in this repo, via the **global mise
config** — see [mise.md](./mise.md).

## rust

`rust` (mise's `core:rust` backend — `rustc` + `cargo`).

Originally added because [eza](./util_tools.md#eza) needs `cargo` to build
(eza has no macOS binary release, and cargo has no standalone install — it
ships with the rest of the toolchain). Kept as a general-purpose language
tool in its own right, not scoped to that one use — confirmed both `rustc`
and `cargo` resolve directly on `PATH`, not just usable internally by
mise's cargo backend. `cargo:eza`'s dependency on it is declared explicitly
in `mise/config.toml` (`depends = ["rust"]`), same pattern used for
`gopls`/`goimports` depending on `go` below.

It's a meaningfully heavier dependency than the static-binary CLI tools in
this repo (a full toolchain vs. an instant binary download) — see
[util_tools.md#eza](./util_tools.md#eza) for the tradeoff that led to adding
it, and why `vfox:eza` (this repo's `disable_backends = ["asdf", "vfox"]`
rule) and skipping eza were the alternatives considered.

## go

`go` (mise's `core:go` backend), plus the dev tooling that goes with it:

- **`gopls`** (via `go:golang.org/x/tools/gopls`) — the Go language server.
  No standalone config file: gopls is configured through LSP client
  initialization options, not a file of its own. Neovim enables it with
  completion, navigation, staticcheck and extra analyses; see
  [nvim.md#lsp](./nvim.md#lsp). Per [AGENTS.md](../AGENTS.md)'s Neovim
  conventions, LSP server *binaries* come from mise (here), and Neovim only
  configures the client — never installs the server itself.
- **`goimports`** (via `go:golang.org/x/tools/cmd/goimports`) — import
  formatter, CLI-flags only, no config file. Conform runs it before `gofumpt`.
- **`golangci-lint`** (via `aqua:golangci/golangci-lint`) — Go meta-linter.
  Checked directly (`golangci-lint config path` against this repo): its
  config file (`.golangci.yml`/`.toml`/`.json`) is discovered by walking up
  from each *Go project's* own directory, with no global/user-level
  fallback — confirmed by the "no config file detected" result here, where
  there's no Go code at all. So there's nothing that belongs in a dotfiles
  repo for it; a per-project `.golangci.yml` is a property of that project,
  not a personal setting. Neovim runs it asynchronously for the current Go
  project with `<leader>cgl`; `<leader>cgL` adds `--fix`. Both publish their
  structured results to a fresh quickfix list and never run on save.
- **`gofumpt`** (via `aqua:mvdan/gofumpt`) — stricter `gofmt`. CLI-flags
  only (`-lang`, `-modpath`, `-extra`, ...), no config file — checked its
  `-h` output directly.
- **`gotestsum`** (via `aqua:gotestyourself/gotestsum`) — nicer `go test`
  output. Also CLI-flags only, no config file of any kind (project-level or
  global) — checked its full `--help` output directly.

`gofumpt` and `gotestsum` are plain aqua binary releases, unlike `gopls`/
`goimports` below — they don't need a local `go` toolchain to install (no
`go install`/`cargo install` step), so they don't carry a `depends = ["go"]`
entry; there'd be nothing for it to order against.

Both `gopls` and `goimports` install via mise's `go:` backend, which runs
`go install <module>@version` — meaning they need a working `go` toolchain
present at install time. That's declared explicitly, not left implicit:

```toml
"go:golang.org/x/tools/gopls" = { version = "0.23.0", depends = ["go"] }
```

Same pattern for `cargo:eza` depending on `rust` above. Verified mise
accepts and parses `depends` without warning (`mise doctor`/`mise config`
clean) and tools still install correctly with it in place. Their
`mise/mise.lock` entries have no per-platform checksums, same reasoning as
[eza's](./util_tools.md#eza) `cargo:` entry: reproducibility comes from the
pinned module version, not a downloaded-binary checksum.

Go's own env-var config file (`GOENV`, for things like `GOPROXY`/`GOFLAGS`)
resolves to `~/Library/Application Support/go/env` on macOS — **not**
XDG's `~/.config/go/env`. Unlike [k9s](./core_tools.md#k9s), this one
doesn't get fixed by [shell/.zshrc exporting `XDG_CONFIG_HOME`](./shell.md):
verified directly (`go env GOENV` with and without it set) that Go's
`os.UserConfigDir()` ignores `XDG_CONFIG_HOME` entirely on Darwin —
unconditionally `~/Library/Application Support`, not read from the
environment at all. Nothing is set there; noted here only so a future "why
isn't `~/.config/go/env` doing anything" doesn't cost time.

## python and Robot Framework

The global config pins Python, basedpyright, Ruff and mypy. Their responsibilities
do not overlap: basedpyright supplies type-aware completion, navigation and
hover with its diagnostics disabled; Ruff supplies live lint diagnostics,
import organization and formatting; mypy is the authoritative static type
checker. Because a project-wide mypy run can be slow, `<leader>cpm` runs it
asynchronously and publishes its JSON output to quickfix instead of running on
every save.

Robot Framework has a global baseline like every other language here:
RobotCode, Robot Framework and Robocop are isolated, pinned `pipx:` tools
installed by mise through the pinned uv binary. RobotCode includes its
language-server, analysis and lint extras.

Neovim uses the same `robot` filetype for `.robot` and `.resource`, pins a
reviewed upstream tree-sitter-robot revision newer than the registry's
`v1.3.0`, and layers RobotCode's language-specific semantic tokens over the
syntax tree. That combination covers the parser's newer grammar fixes while
still highlighting current Robot Framework constructs such as `VAR` and
`GROUP`. Run `:TSUpdate robot` once after pulling a new parser pin.

Local projects still win. For a root containing `.venv/bin/robotcode`, Neovim
launches that exact executable. Otherwise an already activated environment wins
through normal `$PATH` ordering, followed by mise's global RobotCode. When only
project libraries—not RobotCode—exist in `.venv`, their `site-packages` path is
passed to the global server so keyword imports remain visible.

Day-to-day commands need no project installation for a basic suite:

```sh
robot tests/
robotcode analyze code .
robocop check .
robocop format .
```

Projects should still declare their actual test libraries and may pin their own
RobotCode/Robot Framework versions when compatibility requires it. A
conventional `.venv` is discovered automatically; activating it before starting
Neovim remains the escape hatch for any other environment layout.

For Python, mypy discovers normal project configuration in `pyproject.toml`,
`mypy.ini`, `.mypy.ini` or `setup.cfg`. `<leader>cpm` checks from that project
root; a project-local `.venv/bin/mypy` takes precedence over the global binary.

## Editor tooling (LSP, linters, formatters)

Neovim's language support is driven entirely by binaries pinned in the global
mise config — there is no mason.nvim, and Neovim installs nothing. See
[nvim.md#lsp](./nvim.md#lsp) for how they are wired up.

| Tool                           | Backend                            | Role                                             |
| ------------------------------ | ---------------------------------- | ------------------------------------------------ |
| `lua-language-server`          | `aqua:LuaLS/lua-language-server`   | LSP for editing this config                      |
| `rust-analyzer`                | `aqua:rust-lang/rust-analyzer`     | LSP for Rust                                     |
| `basedpyright`                 | `npm:basedpyright`                 | Python completion, navigation and hover          |
| `ruff`                         | `aqua:astral-sh/ruff`              | Python lint, format and complementary LSP        |
| `mypy`                         | `pipx:mypy`                        | Authoritative Python static type checker         |
| `robotcode`                    | `pipx:robotcode`                   | Robot Framework LSP and project analysis         |
| `robot`                        | `pipx:robotframework`              | Robot Framework runner                           |
| `robocop`                      | `pipx:robotframework-robocop`      | Robot Framework lint and formatting              |
| `uv`                           | `aqua:astral-sh/uv`                | Installer for isolated global Python CLIs        |
| `helm-ls`                      | `aqua:mrjosh/helm-ls`              | LSP for Helm charts                              |
| `helm`                         | `aqua:helm/helm`                   | Helm 4 CLI used by helm-ls for chart linting     |
| `hadolint`                     | `aqua:hadolint/hadolint`           | Dockerfile linter                                |
| `kubeconform`                  | `aqua:yannh/kubeconform`           | On-demand Kubernetes manifest validation         |
| `yamlfmt`                      | `aqua:google/yamlfmt`              | YAML and Helm values formatting                  |
| `gomodifytags`                 | `go:github.com/fatih/gomodifytags` | Add/remove Go struct tags                        |
| `impl`                         | `go:github.com/josharian/impl`     | Generate Go interface stubs                      |
| `yaml-language-server`         | `npm:yaml-language-server`         | LSP for YAML and Kubernetes schema-aware editing |
| `vscode-langservers-extracted` | `npm:vscode-langservers-extracted` | LSP for JSON                                     |

`gopls`, `goimports`, `gofumpt`, `golangci-lint` and `gotestsum` were already
present under [go](#go) and are reused as-is.

### Node-backed servers and isolated Python CLIs

**`node` and the three npm servers.** YAML and JSON have no static language
server, and basedpyright's supported distribution is Node-backed. Kubernetes
schema completion and Python type-aware completion are worth that shared
runtime dependency.

**RobotCode, Robot Framework, Robocop and mypy use mise's `pipx:` backend.** uv
creates a separate Python environment for each command, preventing their
dependencies from leaking into projects. All use the globally pinned Python
3.14.7 runtime. RobotCode's environment also pins Robot Framework and Robocop
explicitly, while Neovim's local-first command selection preserves project
overrides.

### `rust-analyzer` and the rustup copy

`rust` is a mise tool, so `~/.cargo/bin` is on `PATH` and rustup can supply its
own `rust-analyzer` there. The `aqua:rust-lang/rust-analyzer` pin exists so a
fresh machine gets a known version rather than depending on whether someone ran
`rustup component add rust-analyzer`. Verified in a login shell that
`rust-analyzer` resolves to the mise copy, not the cargo one.
