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
fi

# setup bun
if command -v bun &> /dev/null; then
  echo "Setting up Bun..."
else
  echo "Warning: Bun not found. It should have been installed via Brewfile."
fi

# setup sdkman
if [ -d "$HOME/.sdkman" ]; then
  echo "SDKMAN already initialized at $HOME/.sdkman"
else
  echo "Initializing SDKMAN..."
  # sdkman-cli from brew needs to be initialized
  if [ -s "/opt/homebrew/opt/sdkman-cli/libexec/bin/sdkman-init.sh" ]; then
    source "/opt/homebrew/opt/sdkman-cli/libexec/bin/sdkman-init.sh"
    
    # add sdkman init to shell profiles
    if ! grep -q "sdkman-init.sh" "$HOME/.zshrc" 2>/dev/null; then
      echo '' >> "$HOME/.zshrc"
      echo '# SDKMAN' >> "$HOME/.zshrc"
      echo 'export SDKMAN_DIR="/opt/homebrew/opt/sdkman-cli/libexec"' >> "$HOME/.zshrc"
      echo '[[ -s "/opt/homebrew/opt/sdkman-cli/libexec/bin/sdkman-init.sh" ]] && source "/opt/homebrew/opt/sdkman-cli/libexec/bin/sdkman-init.sh"' >> "$HOME/.zshrc"
    fi
    
    if ! grep -q "sdkman-init.sh" "$HOME/.bash_profile" 2>/dev/null; then
      echo '' >> "$HOME/.bash_profile"
      echo '# SDKMAN' >> "$HOME/.bash_profile"
      echo 'export SDKMAN_DIR="/opt/homebrew/opt/sdkman-cli/libexec"' >> "$HOME/.bash_profile"
      echo '[[ -s "/opt/homebrew/opt/sdkman-cli/libexec/bin/sdkman-init.sh" ]] && source "/opt/homebrew/opt/sdkman-cli/libexec/bin/sdkman-init.sh"' >> "$HOME/.bash_profile"
    fi
    
    echo "SDKMAN initialized and added to shell profiles"
  else
    echo "Warning: SDKMAN init script not found"
  fi
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
