#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/.agents"
TARGET="$HOME/.agents"
CLAUDE_SKILLS="$HOME/.claude/skills"

link() {
  local source="$1" target="$2" backup

  if [ -L "$target" ]; then
    [ "$(readlink "$target")" = "$source" ] && return 0
    rm "$target"
  elif [ -e "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing $target to $backup"
    mv "$target" "$backup"
  fi

  ln -s "$source" "$target"
  echo "Linked $target -> $source"
}

if [ ! -d "$SOURCE" ]; then
  echo "Error: agents source directory not found at $SOURCE" >&2
  exit 1
fi

echo "Symlinking agents setup..."
link "$SOURCE" "$TARGET"

mkdir -p "$CLAUDE_SKILLS"
for skill in "$SOURCE"/skills/*/; do
  name="$(basename "$skill")"
  if [ -e "$CLAUDE_SKILLS/$name" ] && [ ! -L "$CLAUDE_SKILLS/$name" ]; then
    echo "Skipping $CLAUDE_SKILLS/$name: a real directory is in the way. Remove it to use the dotfiles version."
    continue
  fi
  link "$TARGET/skills/$name" "$CLAUDE_SKILLS/$name"
done

echo "Agents linked for Codex ($TARGET) and Claude Code ($CLAUDE_SKILLS)."
