# jq

No config file here. [jq](https://github.com/jqlang/jq) doesn't have an
application-settings file — its only file-based mechanism is `~/.jq`, a
personal library of custom jq function definitions automatically included
in every invocation. That's fundamentally different from the theme/behavior
config every other tool in this repo has (it's arbitrary user-authored jq
code, not settings), so nothing generic belongs there; skipped rather than
inventing filler content.

The `jq` binary itself is provided by the **global mise config** — see
[mise.md](./mise.md).
