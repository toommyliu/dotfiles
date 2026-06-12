#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/.agents"
TARGET="$HOME/.agents"

if [ ! -d "$SOURCE" ]; then
  echo "Error: agents source directory not found at $SOURCE" >&2
  exit 1
fi

echo "Symlinking agents setup..."

if [ -L "$TARGET" ]; then
  CURRENT_TARGET="$(readlink "$TARGET")"
  if [ "$CURRENT_TARGET" = "$SOURCE" ]; then
    echo "$TARGET already points to $SOURCE"
    exit 0
  fi

  rm "$TARGET"
elif [ -e "$TARGET" ]; then
  BACKUP="$TARGET.backup.$(date +%Y%m%d%H%M%S)"
  echo "Backing up existing $TARGET to $BACKUP"
  mv "$TARGET" "$BACKUP"
fi

ln -s "$SOURCE" "$TARGET"
echo "Agents setup linked: $TARGET -> $SOURCE"
