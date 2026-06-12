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

applications_dir() {
  if [ -d "/Applications" ] && [ -w "/Applications" ]; then
    printf '%s\n' "/Applications"
  else
    mkdir -p "$HOME/Applications"
    printf '%s\n' "$HOME/Applications"
  fi
}

latest_artifact() {
  local app_name="$1"
  local artifact_dir="$2"
  local artifact

  artifact="$(ls -t "$artifact_dir"/"$app_name"-*.zip 2>/dev/null | head -n 1 || true)"

  if [ -z "$artifact" ]; then
    echo "Error: no $app_name artifact found in $artifact_dir." >&2
    exit 1
  fi

  printf '%s\n' "$artifact"
}

install_app_artifact() {
  local app_name="$1"
  local artifact="$2"
  local staging_dir app_path install_dir target

  staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/utility-artifact.XXXXXX")"
  ditto -x -k "$artifact" "$staging_dir"

  app_path="$(find "$staging_dir" -maxdepth 2 -type d -name "$app_name.app" -print -quit)"
  if [ -z "$app_path" ]; then
    echo "Error: $artifact did not contain $app_name.app." >&2
    rm -rf "$staging_dir"
    exit 1
  fi

  install_dir="$(applications_dir)"
  target="$install_dir/$app_name.app"

  echo "Installing $app_name.app to $install_dir..."
  rm -rf "$target"
  ditto "$app_path" "$target"
  rm -rf "$staging_dir"
}

build_perch_artifact() {
  echo "Building Perch artifact..."
  (
    cd "$PROJECTS_DIR/perch"
    ./scripts/perch artifact
  )
  install_app_artifact "Perch" "$(latest_artifact "Perch" "$PROJECTS_DIR/perch/build/artifacts")"
}

build_tally_artifact() {
  echo "Building Tally artifact..."
  (
    cd "$PROJECTS_DIR/tally"
    ./scripts/artifact.sh
  )
  install_app_artifact "Tally" "$(latest_artifact "Tally" "$PROJECTS_DIR/tally/build/artifacts")"
}

echo "Setting up personal utilities..."

mkdir -p "$PROJECTS_DIR"
source_cargo_env

ensure_command git
ensure_command cargo

clone_or_update "wallctl" "https://github.com/toommyliu/wallctl.git"
clone_or_update "dux" "https://github.com/toommyliu/dux.git"
clone_or_update "perch" "https://github.com/toommyliu/perch.git"
clone_or_update "tally" "https://github.com/toommyliu/tally.git"

install_wallctl
install_dux

echo "Building utility artifacts..."
ensure_command xcodebuild
ensure_command ditto
build_perch_artifact
build_tally_artifact

echo "Verifying installs..."
wallctl --version
dux --help >/dev/null

echo "Personal utilities set up, utility artifacts built, and apps installed."
