# Languages

Language toolchains configured in this repo, via the **global mise
config** — see [mise.md](./mise.md).

## rust

`rust` (mise's `core:rust` backend — `rustc` + `cargo`).

Originally added because [eza](./cli_tools.md#eza) needs `cargo` to build
(eza has no macOS binary release, and cargo has no standalone install — it
ships with the rest of the toolchain). Kept as a general-purpose language
tool in its own right, not scoped to that one use — confirmed both `rustc`
and `cargo` resolve directly on `PATH`, not just usable internally by
mise's cargo backend.

It's a meaningfully heavier dependency than the static-binary CLI tools in
this repo (a full toolchain vs. an instant binary download) — see
[cli_tools.md#eza](./cli_tools.md#eza) for the tradeoff that led to adding
it, and why `vfox:eza` (this repo's `disable_backends = ["asdf", "vfox"]`
rule) and skipping eza were the alternatives considered.
