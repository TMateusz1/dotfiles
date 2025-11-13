# Cargo (Rust)
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
## Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

## Volta Node Manager 
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
