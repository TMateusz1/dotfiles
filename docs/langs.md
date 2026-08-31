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
  initialization options, not a file of its own. Not yet wired into
  [nvim/](./nvim.md) — no LSP client config exists there yet either (see
  [nvim.md](./nvim.md)). Per [AGENTS.md](../AGENTS.md)'s Neovim conventions,
  LSP server *binaries* come from mise (here), and Neovim only ever
  configures the client — never installs the server itself.
- **`goimports`** (via `go:golang.org/x/tools/cmd/goimports`) — import
  formatter, CLI-flags only, no config file. Same "not yet wired into nvim"
  situation as gopls.
- **`golangci-lint`** (via `aqua:golangci/golangci-lint`) — Go meta-linter.
  Checked directly (`golangci-lint config path` against this repo): its
  config file (`.golangci.yml`/`.toml`/`.json`) is discovered by walking up
  from each *Go project's* own directory, with no global/user-level
  fallback — confirmed by the "no config file detected" result here, where
  there's no Go code at all. So there's nothing that belongs in a dotfiles
  repo for it; a per-project `.golangci.yml` is a property of that project,
  not a personal setting.
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

## Editor tooling (LSP, linters, formatters)

Neovim's language support is driven entirely by binaries pinned in the global
mise config — there is no mason.nvim, and Neovim installs nothing. See
[nvim.md#lsp](./nvim.md#lsp) for how they are wired up.

| Tool                           | Backend                            | Role                                                          |
| ------------------------------ | ---------------------------------- | ------------------------------------------------------------- |
| `lua-language-server`          | `aqua:LuaLS/lua-language-server`   | LSP for editing this config                                   |
| `rust-analyzer`                | `aqua:rust-lang/rust-analyzer`     | LSP for Rust                                                  |
| `ruff`                         | `aqua:astral-sh/ruff`              | Python lint, format **and** LSP (`ruff server`) in one binary |
| `helm-ls`                      | `aqua:mrjosh/helm-ls`              | LSP for Helm charts                                           |
| `hadolint`                     | `aqua:hadolint/hadolint`           | Dockerfile linter                                             |
| `kubeconform`                  | `aqua:yannh/kubeconform`           | Kubernetes manifest validation                                |
| `gomodifytags`                 | `go:github.com/fatih/gomodifytags` | Add/remove Go struct tags                                     |
| `impl`                         | `go:github.com/josharian/impl`     | Generate Go interface stubs                                   |
| `yaml-language-server`         | `npm:yaml-language-server`         | LSP for YAML and Kubernetes                                   |
| `vscode-langservers-extracted` | `npm:vscode-langservers-extracted` | LSP for JSON                                                  |

`gopls`, `goimports`, `gofumpt`, `golangci-lint` and `gotestsum` were already
present under [go](#go) and are reused as-is.

### Two deliberate exceptions

**`node` and the two npm servers.** Everything else here is a static
single-file binary, which is the standing preference in this repo. YAML and
JSON have no static language server at all, and Kubernetes/CRD schema
completion is worth enough on cloud-native work to accept the dependency.
`node` exists in the global config *only* to run these two; nothing else needs
it. This was weighed against dropping YAML/JSON LSP entirely and relying on
`kubeconform` plus treesitter.

**Robot Framework has no LSP.** Its servers ship only as pip packages, which
would pull a Python chain into the setup for one language. The treesitter
`robot` parser stays, so highlighting and text objects work; completion and
diagnostics do not. Similarly, Python gets no type checker — `basedpyright` is
npm/pip only, and `ruff` already covers lint and format from a single static
binary.

### `rust-analyzer` and the rustup copy

`rust` is a mise tool, so `~/.cargo/bin` is on `PATH` and rustup can supply its
own `rust-analyzer` there. The `aqua:rust-lang/rust-analyzer` pin exists so a
fresh machine gets a known version rather than depending on whether someone ran
`rustup component add rust-analyzer`. Verified in a login shell that
`rust-analyzer` resolves to the mise copy, not the cargo one.
