#!/bin/bash
set -e

export INSTALL_BITWARDEN=""
export INSTALL_ZOOM=""

for arg in "$@"; do
  case $arg in
    --bitwarden)
      INSTALL_BITWARDEN=1
      ;;
    --zoom)
      INSTALL_ZOOM=1
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
  brew bundle --file="$PWD/Brewfile"
else
  echo "Warning: Brewfile not found at $PWD/Brewfile"
fi

# symlink dotfiles
echo "Symlinking dotfiles..."
ln -sf "$PWD/.gitconfig" "$HOME/.gitconfig"
ln -sf "$PWD/.zshrc" "$HOME/.zshrc"

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

echo "Setup complete!"