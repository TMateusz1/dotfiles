# git

`git/` maps to `~/.config/git/` (git's XDG config location). It's split into
topic files rather than one growing config:

- `git/config` — the entry point git actually reads. Currently just
  `[include]`s the topic files below.
- `git/delta.gitconfig` — wires up
  [delta](https://github.com/dandavison/delta) as the diff pager
  (`core.pager`, `interactive.diffFilter`) and themes it with Catppuccin
  Mocha (accent: blue, `#89b4fa`, matching [atuin](./atuin.md)'s accent for
  cross-tool consistency). Diff backgrounds use tinted grounds rather than
  saturated blocks so syntax highlighting stays readable inside a diff; see
  the comments in the file for the exact contrast targets. Also sets
  `merge.conflictStyle = zdiff3` and `diff.colorMoved = default`.

The `delta` binary itself is provided by the **global mise config**, not
installed by git config — see [mise.md](./mise.md).

## Deliberately not here

`git/config` does **not** set `[user]` (name/email) or anything else
machine-/person-specific. This repo is public, and while a git identity
isn't a secret, it doesn't belong in config that gets symlinked as-is across
machines. Identity is left for a not-yet-built bootstrap/install script to
set at install time.
