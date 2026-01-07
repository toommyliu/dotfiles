#!/bin/bash
set -e

HOMEBREW_BUNDLE_INSTALL_BITWARDEN=""
HOMEBREW_BUNDLE_INSTALL_ZOOM=""

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
      exit 0
      ;;
  esac
done

echo "Starting setup..."

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

# install nvm
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# load nvm for current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# install node versions
if command -v nvm &>/dev/null; then
  echo "Installing Node.js versions..."
  nvm install --lts
  nvm install node
  nvm alias default node
  nvm use default
  echo "Node.js versions installed:"
  nvm list
else
  echo "Warning: nvm command not available. Restart your terminal and re-run this script."
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

echo "Setup complete!"