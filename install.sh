#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "./install.sh" ]; then
  echo "❌ Run this script from the dotfiles root (the directory that contains install.sh)." >&2
  exit 1
fi

echo "✅ Looks good, we are in the correct directory: $PWD"

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew not found on this system."
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "✅ Homebrew is installed."
echo "[*] Installing brew packages..."
brew bundle --file="./Brewfile"
echo "✅ Homebrew setup complete."

echo "[*] Ensuring Zsh is the default shell..."

TARGET_SHELL="$(which zsh)"
CURRENT_SHELL="$(dscl . -read /Users/$USER UserShell | awk '{print $2}')"

if [ "$CURRENT_SHELL" != "$TARGET_SHELL" ]; then
  echo "🔧 Changing default shell to: $TARGET_SHELL"
  
  # Add zsh to /etc/shells if it isn't there already
  if ! grep -q "$TARGET_SHELL" /etc/shells; then
    echo "🔧 Adding $TARGET_SHELL to /etc/shells"
    echo "$TARGET_SHELL" | sudo tee -a /etc/shells >/dev/null
  fi

  # Change shell (requires password)
  chsh -s "$TARGET_SHELL"

  echo "✅ Zsh is the default shell now."
else
  echo "✅ Zsh is already the default shell."
fi


# SYMLINKS

echo "[*] Setting up Zsh configs..."

# Target paths in $HOME
ZDOT_ZSHRC="$HOME/.zshrc"
ZDOT_ZSHENV="$HOME/.zshenv"

# Source paths in your repo
ZDOT_SRC_ZSHRC="$PWD/.zshrc"
ZDOT_SRC_ZSHENV="$PWD/.zshenv"

setup_symlink() {
  local source_file="$1"
  local target_file="$2"

  # If target exists and is NOT a symlink → backup
  if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
    local backup="${target_file}.bak-$(date +%Y%m%d-%H%M%S)"
    echo "⚠️  Found existing file $target_file. Backing up to: $backup"
    mv "$target_file" "$backup"
  fi

  # If target is broken symlink → remove it
  if [ -L "$target_file" ] && [ ! -e "$target_file" ]; then
    echo "⚠️  Removing broken symlink: $target_file"
    rm "$target_file"
  fi

  # If symlink exists and is correct → skip
  if [ -L "$target_file" ] && [ "$(readlink "$target_file")" = "$source_file" ]; then
    echo "✅ Symlink already correct: $target_file"
  else
    echo "🔗 Creating symlink: $target_file → $source_file"
    ln -sfn "$source_file" "$target_file"
  fi
}

# Create symlinks
setup_symlink "$ZDOT_SRC_ZSHRC" "$ZDOT_ZSHRC"
setup_symlink "$ZDOT_SRC_ZSHENV" "$ZDOT_ZSHENV"

echo "✅ Zsh config symlinks complete."




echo "[*] Setting up Neovim config..."
NVIM_TARGET="$HOME/.config/nvim"
NVIM_SOURCE="$PWD/nvim"

# If ~/.config does not exist, create it
mkdir -p "$HOME/.config"

# If ~/.config/nvim exists and is NOT a symlink
if [ -e "$NVIM_TARGET" ] && [ ! -L "$NVIM_TARGET" ]; then
  BACKUP="$HOME/.config/nvim.bak-$(date +%Y%m%d-%H%M%S)"
  echo "⚠️  Existing Neovim config found. Backing up to: $BACKUP"
  mv "$NVIM_TARGET" "$BACKUP"
fi

# If ~/.config/nvim is a broken symlink, remove it
if [ -L "$NVIM_TARGET" ] && [ ! -e "$NVIM_TARGET" ]; then
  echo "⚠️  Removing broken symlink: $NVIM_TARGET"
  rm "$NVIM_TARGET"
fi

# If ~/.config/nvim is already the correct symlink → do nothing
if [ -L "$NVIM_TARGET" ] && [ "$(readlink "$NVIM_TARGET")" = "$NVIM_SOURCE" ]; then
  echo "✅ Neovim symlink already exists and is correct."
else
  echo "🔗 Creating Neovim symlink: $NVIM_TARGET → $NVIM_SOURCE"
  ln -sfn "$NVIM_SOURCE" "$NVIM_TARGET"
fi

echo "✅ Neovim setup complete."


echo "[*] Setting up WezTerm config..."

WEZTERM_HOME_FILE="$HOME/.wezterm.lua"
WEZTERM_TARGET_DIR="$HOME/.config/wezterm"
WEZTERM_SOURCE_DIR="$PWD/wezterm"

if [ -e "$WEZTERM_HOME_FILE" ]; then
  BACKUP="$HOME/.wezterm.lua.bak-$(date +%Y%m%d-%H%M%S)"
  echo "⚠️  Found ~/.wezterm.lua. Backing up to: $BACKUP"
  mv "$WEZTERM_HOME_FILE" "$BACKUP"
fi

# Case A: If it exists and is NOT a symlink → backup it
if [ -e "$WEZTERM_TARGET_DIR" ] && [ ! -L "$WEZTERM_TARGET_DIR" ]; then
  BACKUP="$WEZTERM_TARGET_DIR.bak-$(date +%Y%m%d-%H%M%S)"
  echo "⚠️  Found existing wezterm config dir. Backing up to: $BACKUP"
  mv "$WEZTERM_TARGET_DIR" "$BACKUP"
fi

# Case B: If it's a broken symlink → remove it
if [ -L "$WEZTERM_TARGET_DIR" ] && [ ! -e "$WEZTERM_TARGET_DIR" ]; then
  echo "⚠️  Removing broken symlink: $WEZTERM_TARGET_DIR"
  rm "$WEZTERM_TARGET_DIR"
fi

# Case C: If symlink already correct → do nothing
if [ -L "$WEZTERM_TARGET_DIR" ] && [ "$(readlink "$WEZTERM_TARGET_DIR")" = "$WEZTERM_SOURCE_DIR" ]; then
  echo "✅ WezTerm symlink already exists and is correct."
else
  echo "🔗 Creating WezTerm symlink: $WEZTERM_TARGET_DIR → $WEZTERM_SOURCE_DIR"
  ln -sfn "$WEZTERM_SOURCE_DIR" "$WEZTERM_TARGET_DIR"
fi

echo "✅ WezTerm setup complete."

echo "[*] Setting up yamllint config..."

YAMLLINT_TARGET_DIR="$HOME/.config/yamllint"
YAMLLINT_SOURCE_DIR="$PWD/yamllint"

# 1. Ensure ~/.config exists
mkdir -p "$HOME/.config"

# 2. If ~/.config/yamllint exists and is NOT a symlink → backup it
if [ -e "$YAMLLINT_TARGET_DIR" ] && [ ! -L "$YAMLLINT_TARGET_DIR" ]; then
  BACKUP="$YAMLLINT_TARGET_DIR.bak-$(date +%Y%m%d-%H%M%S)"
  echo "⚠️  Found existing yamllint config. Backing up to: $BACKUP"
  mv "$YAMLLINT_TARGET_DIR" "$BACKUP"
fi

# 3. If it's a broken symlink → remove it
if [ -L "$YAMLLINT_TARGET_DIR" ] && [ ! -e "$YAMLLINT_TARGET_DIR" ]; then
  echo "⚠️  Removing broken symlink: $YAMLLINT_TARGET_DIR"
  rm "$YAMLLINT_TARGET_DIR"
fi

# 4. If symlink already correct → do nothing
if [ -L "$YAMLLINT_TARGET_DIR" ] && [ "$(readlink "$YAMLLINT_TARGET_DIR")" = "$YAMLLINT_SOURCE_DIR" ]; then
  echo "✅ yamllint symlink already exists and is correct."
else
  echo "🔗 Creating yamllint symlink: $YAMLLINT_TARGET_DIR → $YAMLLINT_SOURCE_DIR"
  ln -sfn "$YAMLLINT_SOURCE_DIR" "$YAMLLINT_TARGET_DIR"
fi

echo "✅ yamllint setup complete."

echo "[*] Setting up Starship config..."

STARSHIP_TARGET="$HOME/.config/starship.toml"
STARSHIP_SOURCE="$PWD/starship.toml"

# 1. If target exists and is NOT a symlink → backup it
if [ -e "$STARSHIP_TARGET" ] && [ ! -L "$STARSHIP_TARGET" ]; then
  BACKUP="$STARSHIP_TARGET.bak-$(date +%Y%m%d-%H%M%S)"
  echo "⚠️  Found existing starship.toml. Backing up to: $BACKUP"
  mv "$STARSHIP_TARGET" "$BACKUP"
fi

# 2. If it's a broken symlink → remove it
if [ -L "$STARSHIP_TARGET" ] && [ ! -e "$STARSHIP_TARGET" ]; then
  echo "⚠️  Removing broken symlink: $STARSHIP_TARGET"
  rm "$STARSHIP_TARGET"
fi

# 3. If symlink already correct → do nothing
if [ -L "$STARSHIP_TARGET" ] && [ "$(readlink "$STARSHIP_TARGET")" = "$STARSHIP_SOURCE" ]; then
  echo "✅ Starship symlink already exists and is correct."
else
  echo "🔗 Creating Starship symlink: $STARSHIP_TARGET → $STARSHIP_SOURCE"
  ln -sfn "$STARSHIP_SOURCE" "$STARSHIP_TARGET"
fi
echo "✅ Starship setup complete."



# /SYMLINKS


echo "[*] Checking Oh My Zsh..."

OMZ_DIR="$HOME/.oh-my-zsh"
if [ -d "$OMZ_DIR" ]; then
  echo "✅ Oh My Zsh already installed."
else
  echo "🔧 Installing Oh My Zsh (unattended)..."
  RUNZSH="no" CHSH="no" sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended >/dev/null 2>&1

  if [ ! -d "$OMZ_DIR" ]; then
    echo "❌ Oh My Zsh installation failed." >&2
    exit 1
  fi

  echo "🚀 Oh My Zsh installed successfully."
fi

echo "[*] Installing SDKMAN..."
# 1. Detect SDKMAN (safe)
if [ -d "$HOME/.sdkman" ]; then
  echo "✅ SDKMAN already installed. Skipping installation."
else
  echo "🔧 SDKMAN not found. Installing..."
  curl -s "https://get.sdkman.io" | bash >/dev/null 2>&1

  # Validate install
  if [ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    echo "❌ SDKMAN install failed (init script missing)." >&2
    exit 1
  fi
fi
# 2. Load SDKMAN inside a subshell (to avoid ZSH_VERSION error under bash + set -u)
(
  set +u
  # shellcheck disable=SC1090
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  echo "🚀 SDKMAN version: $(sdk version)"
)

echo "[*] Installing Java Corretto..."
JAVA_VERSION="21.0.9-amzn"

(
  set +u
  source "$HOME/.sdkman/bin/sdkman-init.sh" >/dev/null 2>&1

  if sdk home java "$JAVA_VERSION" >/dev/null 2>&1; then
    echo "⚡ Java $JAVA_VERSION already installed."
  else
    echo "🔧 Installing Java $JAVA_VERSION..."
    sdk install java "$JAVA_VERSION" >/dev/null 2>&1
  fi
)

echo "✅ Java setup complete."
echo "✅ SDKMAN + Java setup complete."


echo "[*] Checking Volta installation..."
# 1. Check if Volta is available
if command -v volta >/dev/null 2>&1; then
  echo "✅ Volta already installed."
else
  echo "🔧 Volta not found. Installing..."
  curl https://get.volta.sh | bash -s -- --skip-setup

  # Add Volta to PATH for *this shell* so we can use it immediately
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"

  # Double-check installation success
  if ! command -v volta >/dev/null 2>&1; then
    echo "❌ Volta installation failed." >&2
    exit 1
  fi

  echo "🚀 Volta installed successfully."
fi

# 2. Install Node latest (idempotent)
echo "[*] Installing latest Node with Volta..."

# This is 100% safe — Volta will skip if already installed
volta install node@lts

echo "🚀 Node version: $(node -v)"
echo "🚀 npm version:  $(npm -v)"
echo "✅ Volta + Node setup complete."



echo "[*] Thanks you for using this file, everythings is done... :)"
