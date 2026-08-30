# Bootstrap (symlinks, zsh plugins, desktop apps)

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
mise run bootstrap:all        # both of the above, in one go
mise run bootstrap:all-desktop  # GUI/desktop apps — opt-in, see "Desktop apps" below
```

The tasks are thin wrappers (`mise tasks ls` for the full list) — nothing
they run couldn't be typed out as plain `mise bootstrap dotfiles ...`/
`mise bootstrap repos ...` commands; they just save re-typing the longer
form. Both are idempotent (safe to re-run) and refuse to clobber a real
pre-existing file/directory at any target without `--force`.

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
- **mise** — the global config is two files, and **both** are needed:
  without `mise.lock` alongside `config.toml`, the versions and checksums
  committed in this repo never reach the machine, and mise silently
  maintains its own unpinned lockfile in `~/.config/mise/` instead. (That
  had genuinely happened here before this entry existed — the machine's
  lockfile had drifted, missing `gh`/`neovim`/`glab` and still carrying
  entries from an older dotfiles repo.) `~/.config/mise/` is not symlinked
  wholesale because it also holds machine-local state this repo doesn't own.

`fd`, `jq`, `yq`, `zoxide` have no entries — as documented in
[util_tools.md](./util_tools.md), none of them has a config file to
symlink. `gh` and `glab` are deliberately excluded too: both keep
credentials in the same directory (glab, in the very same file) as their
settings, so neither is safe to symlink into a public repo — see
[util_tools.md#gh](./util_tools.md#gh).

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
# mise.desktop.toml
[bootstrap.packages]
"brew-cask:kitty" = "latest"
"brew-cask:font-jetbrains-mono-nerd-font" = "latest"
```

GUI apps use the same `mise bootstrap` subsystem, via its `brew-cask:`
package manager — **no separate Homebrew installation required**. Verified
directly: hid `brew` entirely from `PATH` and ran `mise bootstrap packages
apply brew-cask:alacritty --dry-run` anyway — it produced a full install
plan (cask, app bundle, binary links, shell completions) with no `brew`
binary present at all. mise fetches cask definitions and performs the
install itself.

**Deliberately isolated from everything else.** `mise.desktop.toml` is
mise's own "config environment" mechanism — a file loaded *only* when
`-E desktop` is passed, never by plain `mise install`, `mise bootstrap`, or
any other task here. Verified directly: `mise bootstrap packages status`
(no `-E desktop`) reports "nothing configured in `[bootstrap.packages]`" —
the desktop entries are structurally invisible, not just conventionally
unused. `bootstrap:all-desktop` is the only task that reaches this file
(`mise -E desktop bootstrap packages apply`), and it isn't a dependency of
`bootstrap:all`.

Both package names were confirmed valid by resolving them directly against
this machine (both already installed via real Homebrew here, unrelated to
this repo — mise refuses to touch a cask Homebrew already owns, the same
non-clobbering stance `[dotfiles]` takes toward an occupied target).

Only one file for all desktop/GUI apps for now (kitty + a font); split into
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

## Current state on this machine

Applied. `mise run bootstrap:status` is the authoritative view; as of the
last check every target above is a live symlink into this repo except three,
all reported as `differs`:

| Target                        | Why it differs                                                                                                         |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `~/.config/nvim`              | still a symlink into an older, unrelated repo (`~/dev/dotfiles2/nvim`) — see [nvim.md](./nvim.md#declared-not-applied) |
| `~/.config/mise/mise.lock`    | a real file mise generated itself, before this repo declared the lockfile entry (see below)                            |
| `~/.config/glow/glamour.json` | a real file, left behind by the earlier whole-directory `glow` symlink                                                 |

All three are occupied targets rather than declaration conflicts, so
`mise bootstrap dotfiles apply --force` resolves them. Nothing here does
that on its own initiative.

The `mise.lock` one is worth understanding before forcing it: the machine's
existing `~/.config/mise/mise.lock` is *not* a copy of this repo's. It had
drifted — missing `gh`, `neovim` and `glab`, and still carrying entries
from the older repo — which is precisely the failure mode that declaring
the lockfile prevents. Forcing replaces that drifted file with the
committed one.

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

### Leftovers from the old repo — still active, not inert

`~/.config/mise/` also contains `config.macos.toml`, `miserc.toml`, and a
pair of `*.backup.<timestamp>` symlinks, all still pointing into
`~/dev/dotfiles2`. **`config.macos.toml` is not dormant:** mise
auto-loads `config.<os>.toml` next to the global config, so it is a live
config layer, and it carries its own `[dotfiles]` table. `mise bootstrap
dotfiles status` shows it managing three targets this repo never declares:

```text
~/Library/Application Support/k9s/config.yaml                  ← config.macos.toml
~/Library/Application Support/k9s/skins/catppuccin-mocha.yaml  ← config.macos.toml
~/Library/Application Support/lazygit/config.yml               ← config.macos.toml
```

Those are the non-XDG macOS paths that this repo deliberately doesn't
target, because `shell/.zshrc` exports `XDG_CONFIG_HOME` and
[k9s](./core_tools.md#k9s)/lazygit therefore resolve to `~/.config/`
instead. Their sources resolve back through `~/.config/` and so currently
land on *this* repo's files — harmless today, but it means a second,
unowned config is quietly duplicating them, and it would break confusingly
if `~/dev/dotfiles2` were ever deleted while these declarations remained.

Clearing out `config.macos.toml`, `miserc.toml` and the two `.backup.`
symlinks is the last step of the migration. Not touched here — they live
outside this repo.
