#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR="$HOME/projects"

source_cargo_env() {
  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
  fi

  export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"
}

ensure_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Error: $command_name is required but was not found on PATH." >&2
    exit 1
  fi
}

clone_or_update() {
  local name="$1"
  local url="$2"
  local repo_dir="$PROJECTS_DIR/$name"

  if [ -d "$repo_dir/.git" ]; then
    if [ -n "$(git -C "$repo_dir" status --porcelain)" ]; then
      echo "$name has local changes; skipping git pull."
    else
      echo "Updating $name..."
      git -C "$repo_dir" pull --ff-only
    fi
  elif [ -e "$repo_dir" ]; then
    echo "Error: $repo_dir exists but is not a git repository." >&2
    exit 1
  else
    echo "Cloning $name..."
    git clone "$url" "$repo_dir"
  fi
}

install_wallctl() {
  echo "Installing wallctl..."
  "$PROJECTS_DIR/wallctl/scripts/install.sh"
}

install_dux() {
  echo "Installing dux..."
  cargo install --path "$PROJECTS_DIR/dux" --locked
}

echo "Installing personal tools..."

mkdir -p "$PROJECTS_DIR"
source_cargo_env

ensure_command git
ensure_command cargo

clone_or_update "wallctl" "https://github.com/toommyliu/wallctl.git"
clone_or_update "dux" "https://github.com/toommyliu/dux.git"

install_wallctl
install_dux

echo "Verifying installs..."
wallctl --version
dux --help >/dev/null

echo "Personal tools installed."
