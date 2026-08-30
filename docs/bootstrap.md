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
"~/.config/glow" = "glow"
"~/.config/bottom" = "bottom"
"~/.config/yazi" = "yazi"
"~/.config/mise/config.toml" = "mise/config.toml"
"~/.config/nvim" = "nvim"
```

**`~/.config/nvim` is declared but has a real pre-existing target on this
machine**, unrelated to this repo's own `nvim/` (see [nvim.md](./nvim.md))
— a different situation from the real `~/.config/mise/config.toml`
conflict above: here it's an existing *directory*, not a conflicting
*declaration*, so `mise bootstrap dotfiles apply --force` would replace
it directly, rather than needing another config edited first. Not applied
by this repo on its own initiative; that's a call for you to make.

Directory entries (`git`, `atuin`, `bat`, ...) symlink the *whole*
directory in one line — e.g. `"~/.config/git" = "git"` brings
`git/config` and `git/delta.gitconfig` along together, since
`git/config`'s own `[include]` already wires in delta. Nothing extra is
needed for delta specifically.

`fd`, `jq`, `yq`, `zoxide` have no entries — as documented in
[util_tools.md](./util_tools.md), none of them has a config file to
symlink.

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
this repo — mise refuses to touch a cask Homebrew already owns, same
non-clobbering behavior as the dotfiles conflict below).

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

## Verified without touching this machine

`mise bootstrap dotfiles status`/`apply` read the **real, live**
`~/.config/mise/config.toml` for merging — `MISE_GLOBAL_CONFIG_FILE`
does *not* redirect this away from it, unlike ordinary tool-config
resolution. So this was validated two ways, neither touching this
machine's real files:

1. Confirmed the schema is well-formed by declaring structurally identical
   `[dotfiles]`/`[bootstrap.repos]` entries in a fully isolated sandbox
   (throwaway `HOME`, throwaway sources) and running `mise bootstrap
   dotfiles status` / `apply --dry-run` / `bootstrap repos status` there —
   correct source resolution, correct planned `ln -sf` commands, correct
   repo tracking.
2. Actually ran `mise bootstrap dotfiles status` against the real
   machine, read-only, to sanity-check integration — and it surfaced a
   real conflict (see below), which is exactly the kind of thing this
   step exists to catch.

**Found, not fixed — needs your decision:** this machine's *real* global
mise config (`~/.config/mise/config.toml`) already has an *entire*
`[dotfiles]` table of its own — not just one stray entry. It's this
machine's leftover declaration from an older dotfiles repo
(`~/dev/dotfiles2`): the file is itself a symlink into that repo (its own
`"~/.config/mise/config.toml" = "config.toml"` line is self-referencing,
resolved relative to dotfiles2's `mise/` directory), and it separately
declares `~/.tmux.conf`, `~/.zshrc`, `~/.config/atuin/config.toml`,
`~/.config/bat/config`, `~/.config/git/delta.gitconfig`,
`~/.config/k9s/config.yaml` (+ its skin), `~/.config/lazygit/config.yml`,
`~/.config/nvim`, and `~/.config/starship.toml` — nearly every path this
repo now also declares. `mise bootstrap dotfiles apply` surfaces these as
"conflicting dotfile declarations" one at a time (first hit is usually
`~/.config/git`, since it's alphabetically early), not all at once.
`--force` does **not** resolve this — `--force` only overrides a real
pre-existing file/directory blocking a symlink target; two configs both
declaring the same target is a different error, and has to be resolved by
removing the losing declaration. The fix is to delete that whole old
`[dotfiles]` table from the real `~/.config/mise/config.toml` (keep
`[tool_alias]`/`[settings]`/`[tools]`) — a one-time edit to a live machine
file, not something this repo's tooling does for you.
