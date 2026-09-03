# Bootstrap (symlinks, Zsh integration, desktop apps)

How this repo actually gets applied to a machine, via mise's own native
`[dotfiles]` and `[bootstrap.repos]` — not a hand-rolled install script.
Declared in the repo-root `mise.toml`. **Nothing here runs automatically**
— not on `mise install`, not via any hook. It's applied explicitly:

```sh
cd ~/dev/dotfiles          # or wherever this repo is cloned
mise run bootstrap:status     # what would change — read-only
mise run bootstrap:dry-run    # preview the dotfile symlinks specifically
mise run bootstrap:dotfiles   # apply symlinks — see "What gets symlinked" below
mise run bootstrap:zsh-plugins  # clone/update oh-my-zsh + its 3 custom plugins
mise run bootstrap:zsh-completion  # install mise's generated Zsh completion
mise run bootstrap:all        # dotfiles + Zsh plugins/completion, in one go
mise run bootstrap:all-desktop  # GUI/desktop apps — opt-in, see "Desktop apps" below
```

The tasks are thin wrappers (`mise tasks ls` for the full list) — nothing
they run couldn't be typed out as plain `mise bootstrap dotfiles ...`/
`mise bootstrap repos ...`/`mise completion zsh --install` commands; they just
save re-typing the longer form. All are idempotent (safe to re-run); the
dotfile and repo bootstrap operations refuse to clobber a real pre-existing
file/directory at any target without `--force`.

## Why mise's own feature, not a script

`mise bootstrap` is a whole declarative provisioning subsystem (accounts,
packages, files, services, repos, dotfiles, ...). We only use two pieces of
it — `[dotfiles]` and `[bootstrap.repos]` — but using them means every
"deferred" placement decision documented across
[util_tools.md](./util_tools.md)/[core_tools.md](./core_tools.md) (tmux's
`~/.tmux.conf`, starship's flat `~/.config/starship.toml`, `shell/.zshrc`
→ `~/.zshrc`) is just an ordinary target/source pair — no special-casing
logic needed, and no restructuring of this repo's existing directory names.

**A key fact this relies on:** relative dotfile `source` paths resolve
against *the directory of the config file that declares the entry* — not
against `dotfiles.root`. So `mise.toml` declaring `"~/.zshrc" =
"shell/.zshrc"` resolves that source relative to the repo root, regardless
of where the repo is cloned or what `dotfiles.root` is set to elsewhere.
This repo deliberately never sets `dotfiles.root` — it isn't needed since
every entry here uses an explicit source, never the home-mirroring `{}`
shorthand.

## What gets symlinked

```toml
[dotfiles]
"~/.zshrc" = "shell/.zshrc"
"~/.tmux.conf" = "tmux/.tmux.conf"
"~/.config/starship.toml" = "starship/starship.toml"
"~/.config/git" = "git"
"~/.config/atuin" = "atuin"
"~/.config/bat" = "bat"
"~/.config/eza" = "eza"
"~/.config/fzf" = "fzf"
"~/.config/ripgrep" = "ripgrep"
"~/.config/lazygit" = "lazygit"
"~/.config/k9s" = "k9s"
"~/.config/kitty" = "kitty"
"~/.config/bottom" = "bottom"
"~/.config/yazi" = "yazi"
"~/.config/nvim" = "nvim"
"~/.config/glow/glamour.json" = "glow/glamour.json"
"~/.config/mise/config.toml" = "mise/config.toml"
"~/.config/mise/mise.lock" = "mise/mise.lock"
"~/.config/mise/config.macos.toml" = "mise/config.macos.toml"
"~/.config/mise/mise.macos.lock" = "mise/mise.macos.lock"
"~/.config/mise/config.desktop.toml" = "mise/config.desktop.toml"
"~/.config/mise/miserc.toml" = "mise/miserc.toml"
```

Directory entries (`git`, `atuin`, `bat`, ...) symlink the *whole*
directory in one line — e.g. `"~/.config/git" = "git"` brings
`git/config` and `git/delta.gitconfig` along together, since
`git/config`'s own `[include]` already wires in delta. Nothing extra is
needed for delta specifically.

Two cases deliberately use **file** entries instead:

- **glow** — glow auto-creates and rewrites its own `glow.yml` in its
  config directory (verified: it reappears after deletion on any plain
  `glow file.md` run). With a directory symlink that write lands inside
  this git repo, which is exactly how a stray `glow/glow.yml` once got
  committed here. Only the theme is symlinked; `glow.yml` stays
  machine-local and is gitignored as a backstop. See
  [util_tools.md#glow](./util_tools.md#glow).
- **mise** — the global setup is managed file-by-file: portable tools use
  `config.toml`/`mise.lock`, the automatically selected macOS Docker layer uses
  `config.macos.toml`/`mise.macos.lock`; `config.desktop.toml` contains the
  opt-in desktop packages; and `miserc.toml` enables platform environments
  early enough for discovery. Every config and lockfile this repo owns is
  symlinked because omitted locks silently become machine-local and can drift.
  `~/.config/mise/` is not symlinked wholesale because it also holds
  machine-local state this repo doesn't own.

`fd`, `jq`, `yq`, `zoxide` have no entries — as documented in
[util_tools.md](./util_tools.md), none of them has a config file to
symlink. `gh` and `glab` are deliberately excluded too: both keep
credentials in the same directory (glab, in the very same file) as their
settings, so neither is safe to symlink into a public repo — see
[util_tools.md#gh](./util_tools.md#gh).

## Zsh completion

`bootstrap:zsh-completion` runs `mise completion zsh --install`, which writes
the generated `_mise` function to
`~/.local/share/zsh/site-functions/_mise`. The file is machine-local generated
state rather than a tracked dotfile: mise owns its format and can refresh it
when mise itself changes.

`bootstrap:all` depends on this task alongside the dotfile and Zsh plugin
tasks, so a fresh machine needs only `mise run bootstrap:all`. The matching
`fpath` entry lives in `shell/.zshrc` before Oh My Zsh loads; Oh My Zsh already
runs `compinit`, so bootstrap does not add a duplicate initialization.

## Zsh plugins

```toml
[bootstrap.repos]
"~/.oh-my-zsh" = { url = "https://github.com/ohmyzsh/ohmyzsh.git", ref = "master" }
"~/.oh-my-zsh/custom/plugins/zsh-autosuggestions" = { url = "...", ref = "v0.7.1" }
"~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" = { url = "...", ref = "0.8.0" }
"~/.oh-my-zsh/custom/plugins/you-should-use" = { url = "...", ref = "1.11.1" }
```

`ref` pins each plugin to a real, current tag (checked directly against
each repo) — reproducible, matching this repo's general "always lock"
stance. oh-my-zsh itself has no tagged releases (it's designed to track
`master` via its own self-update mechanism), so it's pinned to `master`
rather than a specific commit — the one entry here that's a rolling
reference rather than a fixed one.

## Desktop apps

```toml
# mise/config.desktop.toml
[bootstrap.packages]
"brew-cask:kitty" = "latest"
"brew-cask:font-jetbrains-mono-nerd-font" = "latest"
"brew-cask:font-geist-mono-nerd-font" = "latest"
```

GUI apps use the same `mise bootstrap` subsystem, via its `brew-cask:`
package manager — **no separate Homebrew installation required**. Verified
directly: hid `brew` entirely from `PATH` and ran `mise bootstrap packages
apply brew-cask:alacritty --dry-run` anyway — it produced a full install
plan (cask, app bundle, binary links, shell completions) with no `brew`
binary present at all. mise fetches cask definitions and performs the
install itself.

**Deliberately isolated from everything else.** `mise/config.desktop.toml` is
mise's own "config environment" mechanism — a file loaded *only* when
`-E desktop` is passed, never by plain `mise install`, `mise bootstrap`, or
any other task here. Verified directly: `mise bootstrap packages status`
(no `-E desktop`) reports "nothing configured in `[bootstrap.packages]`" —
the desktop entries are structurally invisible, not just conventionally
unused. `bootstrap:all-desktop` is the only task that reaches this file
(`mise -E desktop bootstrap packages apply`), and it remains opt-in rather
than a dependency of `bootstrap:all`.

The normal dotfiles bootstrap symlinks this environment layer to
`~/.config/mise/config.desktop.toml`. `bootstrap:all-desktop` depends on
`bootstrap:all`, so it fully provisions a new desktop machine before applying
the desktop packages.

All three package names were confirmed valid by resolving them directly against
this machine (all already installed via real Homebrew here, unrelated to
this repo — mise refuses to touch a cask Homebrew already owns, the same
non-clobbering stance `[dotfiles]` takes toward an occupied target).

Only one file for all desktop/GUI apps for now (kitty + two fonts); split into
more files only if this grows unwieldy. Not yet extended to Linux
(`flatpak:`/`flatpak-user:`) or the Mac App Store (`mas:`) — same manager
system, addable later without restructuring.

**Installing the app (opt-in) and symlinking its config (not opt-in) are
separate.** `kitty`'s `[dotfiles]` entry lives in the ordinary `mise.toml`
`[dotfiles]` table above, applied by `bootstrap:dotfiles`/`bootstrap:all`
same as everything else — only *installing the kitty binary itself* is
gated behind `bootstrap:all-desktop`. Running `bootstrap:all` without ever
running `bootstrap:all-desktop` leaves a `~/.config/kitty/` symlink in
place for an app that isn't installed yet — harmless, just inert until
kitty is actually installed. See [desktop_tools.md](./desktop_tools.md)
for kitty's own config.

## Checking the current machine

Run `mise run bootstrap:status` for the authoritative view of which declared
targets are live symlinks into this repo. Repository changes never apply or
replace home-directory files automatically.

Three targets needed `--force` on the way there, each because it was
*occupied* by a real file rather than absent:

| Target                        | What was in the way                                                                                                      |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `~/.config/nvim`              | a symlink into an older, unrelated repo (`~/dev/dotfiles2/nvim`) — that repo still exists but nothing here references it |
| `~/.config/mise/mise.lock`    | a lockfile mise generated itself before this repo declared the entry, since drifted (see below)                          |
| `~/.config/glow/glamour.json` | a real file left behind by the earlier whole-directory `glow` symlink                                                    |

The `mise.lock` case is the instructive one: the machine's own lockfile was
*not* a copy of this repo's — it was missing `gh`, `neovim` and `glab` and
still carried entries from the older repo. That drift is precisely the
failure mode the `[dotfiles]` entry exists to prevent.

An occupied target is a different problem from a conflicting *declaration*
(next section), and `--force` only resolves the former.

### A conflict that had to be cleared first (resolved)

`mise bootstrap dotfiles status`/`apply` read the **real, live**
`~/.config/mise/config.toml` when merging declarations —
`MISE_GLOBAL_CONFIG_FILE` does *not* redirect that, unlike ordinary
tool-config resolution. Before this repo was applied, that file was a
symlink into `~/dev/dotfiles2` and carried its own `[dotfiles]` table
declaring nearly every path this repo also declares. mise reports that as
`conflicting dotfile declarations`, one target at a time, and **`--force`
does not help**: `--force` only overrides a real file or directory
occupying a target, whereas two configs declaring the same target is a
different error that can only be fixed by removing the losing declaration.
Deleting that old table was the fix. `~/.config/mise/config.toml` now
symlinks to this repo's `mise/config.toml`, which declares no `[dotfiles]`
at all — the tables live in the repo-root `mise.toml` instead, so the
global config can never conflict with itself this way again.

### One-time migration from the old repo

An earlier setup may still have `config.macos.toml` and `miserc.toml` symlinks
pointing into `~/dev/dotfiles2`. They are active configuration, not inert
leftovers: the old macOS file carries duplicate `[dotfiles]` entries for:

```text
~/Library/Application Support/k9s/config.yaml                  ← config.macos.toml
~/Library/Application Support/k9s/skins/catppuccin-mocha.yaml  ← config.macos.toml
~/Library/Application Support/lazygit/config.yml               ← config.macos.toml
```

This repo deliberately uses the XDG paths instead. Replace the two live old
symlinks with the tracked files, then apply the newly added lockfile:

```sh
mise bootstrap dotfiles apply --force \
  ~/.config/mise/config.macos.toml \
  ~/.config/mise/miserc.toml
mise bootstrap dotfiles apply ~/.config/mise/mise.macos.lock
```

The `*.backup.<timestamp>` symlinks are ignored by mise and can be removed
separately after verifying they are no longer needed.
