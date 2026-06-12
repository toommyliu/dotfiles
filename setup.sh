#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOMEBREW_BUNDLE_INSTALL_BITWARDEN=""
HOMEBREW_BUNDLE_INSTALL_ZOOM=""

is_interactive() {
  [ -t 0 ] && [ -t 1 ]
}

prompt_yes_no() {
  local prompt="$1"
  local reply

  read -r -p "$prompt [y/N] " reply
  case "$reply" in
    [Yy]|[Yy][Ee][Ss])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

for arg in "$@"; do
  case $arg in
    --bitwarden)
      HOMEBREW_BUNDLE_INSTALL_BITWARDEN=1
      ;;
    --zoom)
      HOMEBREW_BUNDLE_INSTALL_ZOOM=1
      ;;
    --help|-h)
      echo "Usage: ./setup.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --bitwarden    Install Bitwarden from Mac App Store (for macOS only)"
      echo "  --zoom         Install Zoom"
      echo "  --help, -h     Show this help message"
      echo ""
      echo "Interactive setup may also prompt to run:"
      echo "  ./setup_raycast.sh"
      echo "  ./setup_tools.sh"
      exit 0
      ;;
  esac
done

echo "Starting setup..."

cd "$SCRIPT_DIR"

# install rosetta 2
if [ ! -d "/usr/libexec/rosetta" ]; then
	echo "Installing Rosetta..."
	sudo softwareupdate --install-rosetta --agree-to-license
	sudo softwareupdate --history
fi

# install xcode cli tools
if ! xcode-select -p &>/dev/null; then
  echo "Installing XCode CLI Tools..."
  xcode-select --install
  echo "Please complete the XCode CLI Tools installation in the dialog, then re-run this script."
  exit 0
else
  echo "XCode CLI Tools already installed at: $(xcode-select -p)"
  xcode-select --version
fi

# install homebrew
BREW_PATH="/opt/homebrew/bin/brew"

if [ ! -f "$BREW_PATH" ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${USER}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"

  brew analytics off
else
  echo "Homebrew already installed at: $BREW_PATH"
fi

# ensure brew is in PATH for current session
eval "$($BREW_PATH shellenv)"

# install packages from Brewfile
if [ -f "$PWD/Brewfile" ]; then
  echo "Installing packages from Brewfile..."
  export HOMEBREW_BUNDLE_INSTALL_BITWARDEN
  export HOMEBREW_BUNDLE_INSTALL_ZOOM
  brew bundle --file="$PWD/Brewfile"
else
  echo "Warning: Brewfile not found at $PWD/Brewfile"
fi

echo "Configuring mise..."
mkdir -p "$HOME/.config/mise"
ln -sf "$PWD/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

if command -v mise &>/dev/null; then
  mise -y install
else
  echo "Error: mise is required but was not found after Homebrew installation."
  exit 1
fi

echo "Configuring pnpm..."
if PNPM_VERSION="$(mise exec -- pnpm --version)"; then
  PNPM_MAJOR_VERSION="${PNPM_VERSION%%.*}"

  if ((PNPM_MAJOR_VERSION < 11)); then
    echo "Error: pnpm 11 or newer is required; found $PNPM_VERSION."
    exit 1
  fi

  mkdir -p "$HOME/Library/Preferences/pnpm"
  mkdir -p "$HOME/Library/pnpm/bin"
  ln -sf "$PWD/.config/pnpm/config.yaml" "$HOME/Library/Preferences/pnpm/config.yaml"
else
  echo "Error: pnpm is required but was not found after mise installation."
  exit 1
fi

echo "Installing Pi..."
if command -v pi &>/dev/null; then
  echo "Pi already installed at: $(command -v pi)"
else
  mise exec -- npm install -g --ignore-scripts --min-release-age=0 --no-fund --no-audit --loglevel=error --progress=false @earendil-works/pi-coding-agent
fi

# symlink ghostty config
echo "Symlinking Ghostty config..."
mkdir -p "$HOME/.config/ghostty"
ln -sf "$PWD/.config/ghostty/config" "$HOME/.config/ghostty/config"

# symlink karabiner config
echo "Symlinking Karabiner config..."
mkdir -p "$HOME/.config/karabiner"
ln -sf "$PWD/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# symlink vscode-settings
echo "Symlinking VS Code settings..."
mkdir -p "$HOME/Library/Application Support/Code/User"
mkdir -p "$HOME/Library/Application Support/Antigravity/User"
ln -sf "$PWD/.config/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
ln -sf "$PWD/.config/vscode/settings.json" "$HOME/Library/Application Support/Antigravity/User/settings.json"

# install oh-my-zsh
echo "Installing oh-my-zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "oh-my-zsh already installed, skipping..."
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# install rust
if [ ! -d "$HOME/.cargo" ]; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
  echo "Rust already installed, skipping..."
fi

# symlink dotfiles
echo "Symlinking dotfiles..."
ln -sf "$PWD/.gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/.zshrc" "$HOME/.zshrc"

if is_interactive; then
  if prompt_yes_no "Set up Raycast?"; then
    "$SCRIPT_DIR/setup_raycast.sh"
  else
    echo "Skipping Raycast setup. Run ./setup_raycast.sh later to import Raycast settings."
  fi

  if prompt_yes_no "Set up personal utilities?"; then
    "$SCRIPT_DIR/setup_tools.sh"
  else
    echo "Skipping personal utilities. Run ./setup_tools.sh later to set up utilities and install app artifacts."
  fi
else
  echo "Skipping interactive optional setup."
  echo "Run ./setup_raycast.sh to import Raycast settings."
  echo "Run ./setup_tools.sh to set up personal utilities and install app artifacts."
fi

echo "Optional services:"
echo "  • Syncthing: brew services start syncthing"

echo "Setup complete!"
