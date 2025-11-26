#!/usr/bin/env bash
set -e

EMAIL="$1"
FILENAME="$2"

if [ -z "$EMAIL" ] || [ -z "$FILENAME" ]; then
  echo "Usage: $0 EMAIL FILENAME"
  exit 1
fi

KEY_FILE="$HOME/.ssh/$FILENAME"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ -f "$KEY_FILE" ]; then
  echo "Key already exists at $KEY_FILE"
else
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE"
fi

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain "$KEY_FILE" 2>/dev/null || ssh-add "$KEY_FILE"

CONFIG_BLOCK="
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $KEY_FILE
"

CONFIG_FILE="$HOME/.ssh/config"
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

if ! grep -q "Host github.com" "$CONFIG_FILE"; then
  echo "$CONFIG_BLOCK" >> "$CONFIG_FILE"
fi

cat "${KEY_FILE}.pub"
