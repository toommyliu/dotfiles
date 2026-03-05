#!/bin/bash

set -e

# https://macos-defaults.com/dock/autohide-time-modifier.html

echo "Disabling startup sound..."
sudo nvram StartupMute=%01

echo "Configuring trackpad..."
  # Tap to click
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  sudo defaults write /Library/Preferences/.GlobalPreferences com.apple.mouse.tapBehavior -int 1 # update System Settings
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

  # App Expose (Swipe Down with Three Fingers)
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipe -int 1
  defaults write com.apple.dock showAppExposeGestureEnabled -bool true
  defaults write com.apple.dock appExposeGestureEnabled -int 1

echo "Configuring finder..."
  defaults write com.apple.finder ShowPathbar -bool true  # Show path bar in Finder
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false  # Disable extension change warning
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # Default to List view

echo "Configuring dock..."
  defaults write com.apple.dock orientation -string "left"
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock show-recents -bool false
  defaults write com.apple.dock autohide-delay -float 0.1 # time to trigger
  defaults write com.apple.dock autohide-time-modifier -float 0.25 # open/close animation time

  # Remove persistent items (Downloads, Recent Apps, etc)
  defaults delete com.apple.dock persistent-others 2>/dev/null || true

  dockutil --remove all --no-restart

  # Add apps in specified order
    # Finder would be here
    dockutil --add /System/Applications/Messages.app --no-restart
    dockutil --add /System/Applications/Mail.app --no-restart
    dockutil --add /Applications/Notion.app --no-restart
    dockutil --add /Applications/Obsidian.app --no-restart
    dockutil --add '/Applications/Notion Calendar.app' --no-restart
    dockutil --add /System/Applications/Notes.app --no-restart
    dockutil --add /Applications/Reminders.app --no-restart
    dockutil --add /Applications/Helium.app --no-restart
    dockutil --add /Applications/Legcord.app --no-restart
    dockutil --add /Applications/Spotify.app --no-restart
    dockutil --add "/Applications/Visual Studio Code.app" --no-restart
    dockutil --add /Applications/Antigravity.app --no-restart
    dockutil --add /Applications/Zed.app --no-restart
    dockutil --add /Applications/Ghostty.app --no-restart
    dockutil --add "/Applications/Sublime Merge.app" --no-restart

killall Dock
killall Finder

read -p "restart? [y/N]: " answer

answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
    sudo shutdown -r now
else
    echo "Setup complete!"
fi
