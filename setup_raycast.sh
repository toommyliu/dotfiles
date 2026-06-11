#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAYCAST_CONFIG_DIR="$SCRIPT_DIR/.config/raycast"
RAYCAST_APP="/Applications/Raycast.app"

if [ ! -d "$RAYCAST_CONFIG_DIR" ]; then
  echo "Error: Raycast config directory not found at $RAYCAST_CONFIG_DIR"
  exit 1
fi

CONFIG_FILE="$(find "$RAYCAST_CONFIG_DIR" -maxdepth 1 -type f -name "*.rayconfig" -print0 | xargs -0 ls -t 2>/dev/null | head -n 1 || true)"

if [ -z "$CONFIG_FILE" ]; then
  echo "Error: no .rayconfig files found in $RAYCAST_CONFIG_DIR"
  exit 1
fi

if [ ! -d "$RAYCAST_APP" ]; then
  echo "Error: Raycast is not installed at $RAYCAST_APP"
  echo "Run ./setup.sh first to install Raycast via Homebrew."
  exit 1
fi

echo "Using Raycast config: $CONFIG_FILE"
echo "Opening Raycast import..."
open -a Raycast "$CONFIG_FILE"

echo "Enter the config password and confirm the import in Raycast if prompted."
