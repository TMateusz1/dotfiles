# Languages

The global mise config pins language runtimes and compilers. Zed and its
extensions manage language servers and editor formatting tools separately.
Project dependencies and command-line checks belong in each project's own
configuration. See [mise](./mise.md) and
[Zed languages and formatting](./desktop_tools.md#languages-and-formatting).

## Rust

Mise pins Rust (`rustc` and `cargo`) for projects and the `cargo:eza` install.
Zed uses rust-analyzer for completion, navigation and diagnostics, with
build-script and procedural-macro support and Clippy checks on save.
Formatting uses the active toolchain's rustfmt and project formatting rules.

The toolchain needs `clippy`, `rustfmt` and `rust-src`. If missing, install
these components for the active toolchain:

```sh
rustup component add clippy rustfmt rust-src
```

Zed's shared test tasks invoke Cargo directly for individual tests, packages
and workspaces. See [Zed testing](./desktop_tools.md#zed).

## Go

Mise pins Go. Zed uses gopls for completion, navigation, formatting and
Staticcheck diagnostics. Import organization runs before formatting, and
gopls enables its integrated gofumpt formatter. Shared test tasks invoke
`go test` directly; Go snippets live in `zed/snippets/go.json`.

Go's `GOENV` path on macOS is `~/Library/Application Support/go/env`, independent
of `XDG_CONFIG_HOME`; no file is provisioned there.

## Python and other project languages

Mise pins Python, Node and uv. Python projects should declare their dependencies
and virtual environments locally. Node supports JavaScript/TypeScript projects
and npm-based tooling; Zed uses vtsls and Prettier for those languages.

Python, Robot Framework, Protocol Buffers and Kotlin no longer have a shared
package-installation list in this repository. Configure the needed Zed language
support and project toolchain for each workflow. This repository does not
provision their language-server, formatter or linter executables separately.
Java/Kotlin project JDKs and build tools also remain project dependencies.

## Configuration languages and Kubernetes

Zed's shared settings configure JSON/JSONC, YAML, TOML and Markdown support.
See [languages and formatting](./desktop_tools.md#languages-and-formatting)
for the selected language servers, extensions and formatters.

Mise retains Helm, kind and k9s for Kubernetes workflows, plus jq and yq for
shell processing. Repository-local mise independently pins Taplo, yamlfmt,
rumdl and ShellCheck for hk; editor formatting does not replace these checks.
