#!/bin/bash

set -e

# configure trackpad
echo "Configuring trackpad..."

  # tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# configure finder
echo "Configuring finder..."
  defaults write com.apple.finder ShowPathbar -bool true  # Show path bar in Finder
  defaults write com.apple.finder ShowStatusBar -bool true  # Show status bar in Finder
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false  # Disable extension change warning

# configure dock
echo "Configuring dock..."
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
    dockutil --add "/Applications/Sublime Merge.app" --no-restart

# restart apps to apply all changes
killall Dock
killall Finder

echo "Setup complete!"
