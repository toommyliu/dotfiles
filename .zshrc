# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

function _gb_delete_if_remote_merged() {
  local branch="$1"
  local remote_head="$2"
  local merge_base synthetic

  [[ -z "$branch" || -z "$remote_head" ]] && return 1

  if command git merge-base --is-ancestor "$branch" "$remote_head"; then
    command git branch -D -- "$branch"
    return $?
  fi

  merge_base="$(command git merge-base "$remote_head" "$branch")" || return 1
  synthetic="$(command git commit-tree "$(command git rev-parse "$branch^{tree}")" -p "$merge_base" -m _)" || return 1

  if [[ "$(command git cherry "$remote_head" "$synthetic")" == -* ]]; then
    command git branch -D -- "$branch"
    return $?
  fi

  return 1
}

function _gb_remote_merged_setup() {
  local target="$1"
  local remote=origin
  local remote_head="${remote}/HEAD"
  local current_branch current_upstream protected resolved_target
  local -a protected_branches

  command git rev-parse --git-dir &>/dev/null || return
  command git fetch --prune "$remote" || return

  if [[ -n "$target" ]]; then
    [[ "$target" == */* ]] && resolved_target="$target" || resolved_target="${remote}/${target}"
  else
    current_branch="$(command git branch --show-current)"
    current_upstream="$(command git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"
    protected_branches=(main master trunk develop development dev devel)

    for protected in "${protected_branches[@]}"; do
      if [[ "$current_branch" == "$protected" && "$current_upstream" == "$remote"/* ]]; then
        resolved_target="$current_upstream"
        break
      fi
    done

    [[ -n "$resolved_target" ]] || resolved_target="$remote_head"
  fi

  resolved_target="$(command git rev-parse --abbrev-ref "$resolved_target" 2>/dev/null)"
  if [[ -z "$resolved_target" ]]; then
    echo "git branch cleanup: unable to resolve target"
    return 1
  fi

  echo "$resolved_target"
}

# Delete local branches already on the current trunk upstream, including squash/rebase merges.
function gbdr() {
  local target_ref current_branch target_branch branch protected
  local -a protected_branches

  target_ref="$(_gb_remote_merged_setup "$1")" || return
  current_branch="$(command git branch --show-current)"
  target_branch="${target_ref#*/}"
  protected_branches=(main master trunk develop development dev devel "$target_branch")

  command git for-each-ref refs/heads/ --format='%(refname:short)' | while read -r branch; do
    [[ -z "$branch" || "$branch" == "$current_branch" ]] && continue

    for protected in "${protected_branches[@]}"; do
      [[ "$branch" == "$protected" ]] && continue 2
    done

    _gb_delete_if_remote_merged "$branch" "$target_ref"
  done
}
compdef _git gbdr=git-branch

# Make the stock "gone branch delete" alias squash/rebase-aware.
unalias gbgd 2>/dev/null
function gbgd() {
  local target_ref current_branch target_branch branch track protected
  local -a protected_branches

  target_ref="$(_gb_remote_merged_setup "$1")" || return
  current_branch="$(command git branch --show-current)"
  target_branch="${target_ref#*/}"
  protected_branches=(main master trunk develop development dev devel "$target_branch")

  command git for-each-ref refs/heads/ --format='%(refname:short) %(upstream:track)' | while read -r branch track; do
    [[ "$track" == "[gone]" ]] || continue
    [[ -z "$branch" || "$branch" == "$current_branch" ]] && continue

    for protected in "${protected_branches[@]}"; do
      [[ "$branch" == "$protected" ]] && continue 2
    done

    _gb_delete_if_remote_merged "$branch" "$target_ref"
  done
}
compdef _git gbgd=git-branch

# DISABLE_MAGIC_FUNCTIONS="true"

typeset -U path PATH

# fnm
eval "$(fnm env --use-on-cd)"

# SDKMAN
export SDKMAN_DIR="/opt/homebrew/opt/sdkman-cli/libexec"
if [[ -d "${SDKMAN_DIR}/candidates/java/current" ]]; then
  export JAVA_HOME="${SDKMAN_DIR}/candidates/java/current"
  export PATH="${JAVA_HOME}/bin:${PATH}"
fi

if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
  sdk() {
    unfunction sdk
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
    sdk "$@"
  }
fi

# Go
if command -v go &>/dev/null; then
  export GOPATH="$HOME/go"
  export PATH="$GOPATH/bin:$PATH"
fi

# Python 3.13
if [[ -d /opt/homebrew/opt/python@3.13/bin ]]; then
  export PATH="/opt/homebrew/opt/python@3.13/bin:$PATH"
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d "$PNPM_HOME" ]] && export PATH="$PNPM_HOME:$PATH"
[[ -d "$PNPM_HOME/bin" ]] && export PATH="$PNPM_HOME/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Added by Antigravity
export PATH="/Users/tommyliu/.antigravity/antigravity/bin:$PATH"
# Added by Antigravity IDE
export PATH="/Users/tommyliu/.antigravity-ide/antigravity-ide/bin:$PATH"

# bun completions
[ -s "/Users/tommyliu/.bun/_bun" ] && source "/Users/tommyliu/.bun/_bun"
