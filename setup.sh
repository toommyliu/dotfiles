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

add_shell_config() {
  local marker="$1"
  local header="$2"
  shift 2
  
  if ! grep -q "$marker" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo "# $header" >> "$HOME/.zshrc"
    for line in "$@"; do
      echo "$line" >> "$HOME/.zshrc"
    done
    echo "$header configuration added to shell profile"
  fi
}

echo "Starting setup..."

# install rosetta 2
if [ ! -d "/usr/libexec/rosetta" ]; then
	echo "Installing Rosetta..."
	sudo softwareupdate --install-rosetta --agree-to-license
	# verify install
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

  # add homebrew to PATH
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${USER}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # turn off brew analytics
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

# install nvm using official install script
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  
  # load nvm for current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
  echo "NVM already installed at $HOME/.nvm"
  # load nvm for current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# ensure nvm is in PATH (the install script should do this, but we'll verify)
add_shell_config "NVM_DIR" "NVM" \
  'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' \
  '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' \
  '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

# install node versions using nvm
if command -v nvm &>/dev/null; then
  echo "Installing Node.js versions..."
  nvm install --lts
  nvm install node
  nvm alias default node
  nvm use default
  echo "Node.js versions installed:"
  nvm list
else
  echo "Warning: nvm command not available. You may need to restart your terminal and re-run this script."
fi

# setup sdkman
echo "Setting up SDKMAN..."
SDKMAN_BREW_DIR="$(brew --prefix sdkman-cli)/libexec"

if [ -s "${SDKMAN_BREW_DIR}/bin/sdkman-init.sh" ]; then
  add_shell_config "sdkman-init.sh" "SDKMAN" \
    'export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"' \
    '[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"'
  echo "Open a new terminal and run 'sdk version' to verify installation"
else
  echo "Warning: SDKMAN init script not found at ${SDKMAN_BREW_DIR}/bin/sdkman-init.sh"
fi

# setup Go
echo "Setting up Go..."
if command -v go &>/dev/null; then
  add_shell_config "GOPATH" "Go" \
    'export GOPATH="$HOME/go"' \
    'export PATH="$GOPATH/bin:$PATH"'
fi

# setup Python 3.13
echo "Setting up Python 3.13..."
if brew list python@3.13 &>/dev/null; then
  add_shell_config "python@3.13" "Python 3.13" \
    "export PATH=\"$(brew --prefix python@3.13)/bin:\$PATH\""
fi

# setup pnpm
echo "Setting up pnpm..."
if command -v pnpm &>/dev/null; then
  add_shell_config "PNPM_HOME" "pnpm" \
    'export PNPM_HOME="$HOME/Library/pnpm"' \
    'export PATH="$PNPM_HOME:$PATH"'
fi

# setup bun
echo "Setting up bun..."
if command -v bun &>/dev/null; then
  add_shell_config "BUN_INSTALL" "bun" \
    'export BUN_INSTALL="$HOME/.bun"' \
    'export PATH="$BUN_INSTALL/bin:$PATH"'
fi