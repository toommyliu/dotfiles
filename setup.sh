#!/bin/bash

echo "Starting setup..."

# install rosetta on apple silicon
if [[ "$(sysctl -n machdep.cpu.brand_string)" == *'Apple'* ]]; then
	if [ ! -d "/usr/libexec/rosetta" ]; then
		echo "Installing Rosetta..."
		sudo softwareupdate --install-rosetta --agree-to-license
	fi

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
if [[ "$(sysctl -n machdep.cpu.brand_string)" == *'Apple'* ]]; then
  BREW_PATH="/opt/homebrew/bin/brew"
else
  BREW_PATH="/usr/local/bin/brew"
fi

if [ ! -f "$BREW_PATH" ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # add 'brew --prefix' location to $PATH
  # https://applehelpwriter.com/2018/03/21/how-homebrew-invites-users-to-get-pwned/
  # https://www.n00py.io/2016/10/privilege-escalation-on-os-x-without-exploits/
  if [[ "$(sysctl -n machdep.cpu.brand_string)" == *'Apple'* ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${USER}/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${USER}/.bash_profile
    eval "$(/opt/homebrew/bin/brew shellenv)"

    #echo 'export PATH=/opt/homebrew/bin:$PATH' >> /Users/${USER}/.bash_profile
    #echo 'export PATH=/opt/homebrew/sbin:$PATH' >> /Users/${USER}/.bash_profile
  else
    echo 'export PATH="/usr/local/sbin:$PATH"' >> /Users/${USER}/.bash_profile
  fi

  source /Users/${USER}/.bash_profile

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

# setup nvm and install node versions
if [ -d "$HOME/.nvm" ]; then
  echo "Setting up NVM and installing Node.js versions..."
  
  if ! grep -q "nvm.sh" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '# NVM' >> "$HOME/.zshrc"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.zshrc"
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm' >> "$HOME/.zshrc"
    echo '[ -s "/opt/homebrew/opt/nvm/bash_completion" ] && \. "/opt/homebrew/opt/nvm/bash_completion"  # This loads nvm bash_completion' >> "$HOME/.zshrc"
  fi
  
  if ! grep -q "nvm.sh" "$HOME/.bash_profile" 2>/dev/null; then
    echo '' >> "$HOME/.bash_profile"
    echo '# NVM' >> "$HOME/.bash_profile"
    echo 'export NVM_DIR="$HOME/.nvm"' >> "$HOME/.bash_profile"
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm' >> "$HOME/.bash_profile"
    echo '[ -s "/opt/homebrew/opt/nvm/bash_completion" ] && \. "/opt/homebrew/opt/nvm/bash_completion"  # This loads nvm bash_completion' >> "$HOME/.bash_profile"
  fi
  
  # load nvm for current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

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
  
  echo "NVM configuration added to shell profiles"
fi

# setup sdkman
echo "Setting up SDKMAN..."
SDKMAN_BREW_DIR="$(brew --prefix sdkman-cli)/libexec"

if [ -s "${SDKMAN_BREW_DIR}/bin/sdkman-init.sh" ]; then
  if ! grep -q "sdkman-init.sh" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '# SDKMAN' >> "$HOME/.zshrc"
    echo 'export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"' >> "$HOME/.zshrc"
    echo '[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"' >> "$HOME/.zshrc"
  fi
  
  if ! grep -q "sdkman-init.sh" "$HOME/.bash_profile" 2>/dev/null; then
    echo '' >> "$HOME/.bash_profile"
    echo '# SDKMAN' >> "$HOME/.bash_profile"
    echo 'export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"' >> "$HOME/.bash_profile"
    echo '[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"' >> "$HOME/.bash_profile"
  fi
  
  echo "SDKMAN configuration added to shell profiles"
  echo "Open a new terminal and run 'sdk version' to verify installation"
else
  echo "Warning: SDKMAN init script not found at ${SDKMAN_BREW_DIR}/bin/sdkman-init.sh"
fi

# setup Go
echo "Setting up Go..."
if command -v go &>/dev/null; then
  if ! grep -q "GOPATH" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '# Go' >> "$HOME/.zshrc"
    echo 'export GOPATH="$HOME/go"' >> "$HOME/.zshrc"
    echo 'export PATH="$GOPATH/bin:$PATH"' >> "$HOME/.zshrc"
  fi
  
  if ! grep -q "GOPATH" "$HOME/.bash_profile" 2>/dev/null; then
    echo '' >> "$HOME/.bash_profile"
    echo '# Go' >> "$HOME/.bash_profile"
    echo 'export GOPATH="$HOME/go"' >> "$HOME/.bash_profile"
    echo 'export PATH="$GOPATH/bin:$PATH"' >> "$HOME/.bash_profile"
  fi
  
  echo "Go configuration added to shell profiles"
fi

# setup Python 3.13
echo "Setting up Python 3.13..."
if brew list python@3.13 &>/dev/null; then
  PYTHON_PATH="$(brew --prefix python@3.13)/bin"
  
  if ! grep -q "python@3.13" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '# Python 3.13' >> "$HOME/.zshrc"
    echo "export PATH=\"$(brew --prefix python@3.13)/bin:\$PATH\"" >> "$HOME/.zshrc"
  fi
  
  if ! grep -q "python@3.13" "$HOME/.bash_profile" 2>/dev/null; then
    echo '' >> "$HOME/.bash_profile"
    echo '# Python 3.13' >> "$HOME/.bash_profile"
    echo "export PATH=\"$(brew --prefix python@3.13)/bin:\$PATH\"" >> "$HOME/.bash_profile"
  fi
  
  echo "Python 3.13 configuration added to shell profiles"
fi

# setup pnpm
echo "Setting up pnpm..."
if command -v pnpm &>/dev/null; then
  if ! grep -q "PNPM_HOME" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '# pnpm' >> "$HOME/.zshrc"
    echo 'export PNPM_HOME="$HOME/Library/pnpm"' >> "$HOME/.zshrc"
    echo 'export PATH="$PNPM_HOME:$PATH"' >> "$HOME/.zshrc"
  fi
  
  if ! grep -q "PNPM_HOME" "$HOME/.bash_profile" 2>/dev/null; then
    echo '' >> "$HOME/.bash_profile"
    echo '# pnpm' >> "$HOME/.bash_profile"
    echo 'export PNPM_HOME="$HOME/Library/pnpm"' >> "$HOME/.bash_profile"
    echo 'export PATH="$PNPM_HOME:$PATH"' >> "$HOME/.bash_profile"
  fi
  
  echo "pnpm configuration added to shell profiles"
fi

# setup bun
echo "Setting up bun..."
if command -v bun &>/dev/null; then
  if ! grep -q "BUN_INSTALL" "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '# bun' >> "$HOME/.zshrc"
    echo 'export BUN_INSTALL="$HOME/.bun"' >> "$HOME/.zshrc"
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$HOME/.zshrc"
  fi
  
  if ! grep -q "BUN_INSTALL" "$HOME/.bash_profile" 2>/dev/null; then
    echo '' >> "$HOME/.bash_profile"
    echo '# bun' >> "$HOME/.bash_profile"
    echo 'export BUN_INSTALL="$HOME/.bun"' >> "$HOME/.bash_profile"
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$HOME/.bash_profile"
  fi
  
  echo "bun configuration added to shell profiles"
fi

# configure macOS
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
  
  # restart dock to apply all changes
  killall Dock

echo "Setup complete!"
