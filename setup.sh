#!/bin/bash
set -e

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

# ensure nvm is in PATH configuration files (the install script should do this, but we'll verify)
if ! grep -q "NVM_DIR" "$PWD/.zshrc" 2>/dev/null; then
  echo '' >> "$PWD/.zshrc"
  echo '# NVM' >> "$PWD/.zshrc"
  echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> "$PWD/.zshrc"
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> "$PWD/.zshrc"
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> "$PWD/.zshrc"
fi

# install node versions using nvm
if command -v nvm &>/dev/null; then
  echo "Installing Node.js versions..."
  
  # install latest LTS version
  echo "Installing Node.js LTS..."
  nvm install --lts

  # install latest version
  echo "Installing latest Node.js..."
  nvm install node

  # set latest as default
  nvm alias default node
  nvm use default

  echo "Node.js versions installed:"
  nvm list
  echo "Default version:"
  node --version
else
  echo "Warning: nvm command not available. You may need to restart your terminal and re-run this script."
fi

# setup sdkman
echo "Setting up SDKMAN..."
SDKMAN_BREW_DIR="$(brew --prefix sdkman-cli)/libexec"

if [ -s "${SDKMAN_BREW_DIR}/bin/sdkman-init.sh" ]; then
  if ! grep -q "sdkman-init.sh" "$PWD/.zshrc" 2>/dev/null; then
    echo '' >> "$PWD/.zshrc"
    echo '# SDKMAN' >> "$PWD/.zshrc"
    echo 'export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"' >> "$PWD/.zshrc"
    echo '[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"' >> "$PWD/.zshrc"
  fi
  
  echo "SDKMAN configuration added to shell profiles"
  echo "Open a new terminal and run 'sdk version' to verify installation"
else
  echo "Warning: SDKMAN init script not found at ${SDKMAN_BREW_DIR}/bin/sdkman-init.sh"
fi

# setup Go
echo "Setting up Go..."
if command -v go &>/dev/null; then
  if ! grep -q "GOPATH" "$PWD/.zshrc" 2>/dev/null; then
    echo '' >> "$PWD/.zshrc"
    echo '# Go' >> "$PWD/.zshrc"
    echo 'export GOPATH="$HOME/go"' >> "$PWD/.zshrc"
    echo 'export PATH="$GOPATH/bin:$PATH"' >> "$PWD/.zshrc"
  fi
  
  echo "Go configuration added to shell profiles"
fi

# setup Python 3.13
echo "Setting up Python 3.13..."
if brew list python@3.13 &>/dev/null; then
  PYTHON_PATH="$(brew --prefix python@3.13)/bin"
  
  if ! grep -q "python@3.13" "$PWD/.zshrc" 2>/dev/null; then
    echo '' >> "$PWD/.zshrc"
    echo '# Python 3.13' >> "$PWD/.zshrc"
    echo "export PATH=\"$(brew --prefix python@3.13)/bin:\$PATH\"" >> "$PWD/.zshrc"
  fi
  
  echo "Python 3.13 configuration added to shell profiles"
fi

# setup pnpm
echo "Setting up pnpm..."
if command -v pnpm &>/dev/null; then
  if ! grep -q "PNPM_HOME" "$PWD/.zshrc" 2>/dev/null; then
    echo '' >> "$PWD/.zshrc"
    echo '# pnpm' >> "$PWD/.zshrc"
    echo 'export PNPM_HOME="$HOME/Library/pnpm"' >> "$PWD/.zshrc"
    echo 'export PATH="$PNPM_HOME:$PATH"' >> "$PWD/.zshrc"
  fi
  
  echo "pnpm configuration added to shell profiles"
fi

# setup bun
echo "Setting up bun..."
if command -v bun &>/dev/null; then
  if ! grep -q "BUN_INSTALL" "$PWD/.zshrc" 2>/dev/null; then
    echo '' >> "$PWD/.zshrc"
    echo '# bun' >> "$PWD/.zshrc"
    echo 'export BUN_INSTALL="$HOME/.bun"' >> "$PWD/.zshrc"
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$PWD/.zshrc"
  fi
  
  echo "bun configuration added to shell profiles"
fi

# configure macOS
  # configure macOS Finder
  echo "Configuring macOS Finder..."
  defaults write com.apple.finder ShowPathbar -bool true  # Show path bar in Finder
  defaults write com.apple.finder ShowStatusBar -bool true  # Show status bar in Finder
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false  # Disable extension change warning

  # configure macOS Dock
  echo "Configuring macOS Dock..."
  
  # configure dock preferences
  defaults write com.apple.dock orientation -string "left"
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock show-recents -bool false
  
  # remove persistent items (Downloads, Recent Apps, etc)
  defaults delete com.apple.dock persistent-others 2>/dev/null || true
  
  # clear all apps from dock to start fresh
  dockutil --remove all --no-restart
  
  # add apps in specified order
  # finder would be here
  dockutil --add /System/Applications/Messages.app --no-restart
  dockutil --add /System/Applications/Mail.app --no-restart
  dockutil --add /Applications/Notion.app --no-restart
  dockutil --add /System/Applications/Notes.app --no-restart
  dockutil --add /Applications/Todoist.app --no-restart
  dockutil --add /Applications/Helium.app --no-restart
  dockutil --add /Applications/Discord.app --no-restart
  dockutil --add /Applications/Spotify.app --no-restart
  dockutil --add "/Applications/Visual Studio Code.app" --no-restart
  dockutil --add /Applications/Zed.app --no-restart
  dockutil --add /Applications/Ghostty.app --no-restart
  dockutil --add "/Applications/Sublime Merge.app"
  
  # restart apps to apply all changes
  killall Dock
  killall Finder

echo "Setup complete!"
