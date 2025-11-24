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
command -v "xcode-select -p" >/dev/null 2>&1; has_xcode=1 || { has_xcode=0; }
if [ "$has_xcode" -eq 0 ]; then
  echo "Installing XCode CLI Tools..."
  sudo xcode-select --install
else
  # verify install
  xcode-select -p
  xcode-select --version
fi

# install homebrew
command -v brew >/dev/null 2>&1; has_brew=1 || { has_brew=0; }
if [ "$has_brew" -eq 0 ]; then
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
