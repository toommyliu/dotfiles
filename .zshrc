# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

_gb_protected=(main master trunk develop development dev devel)

function _gb_target() {
  local target="$1" upstream
  if [[ -z "$target" ]]; then
    upstream="$(command git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)"
    if (( ${_gb_protected[(Ie)$(command git branch --show-current)]} )) && [[ "$upstream" == origin/* ]]; then
      target="$upstream"
    else
      target=origin/HEAD
    fi
  fi
  [[ "$target" == */* ]] || target="origin/$target"
  command git rev-parse --abbrev-ref "$target" 2>/dev/null || {
    echo "git branch cleanup: unable to resolve $target" >&2
    return 1
  }
}

function _gb_is_merged() {
  local branch="$1" target="$2" pr_head="$3" base synthetic
  command git merge-base --is-ancestor "$branch" "$target" && return 0
  base="$(command git merge-base "$target" "$branch")" || return 1
  synthetic="$(command git commit-tree "$branch^{tree}" -p "$base" -m _)" || return 1
  [[ "$(command git cherry "$target" "$synthetic")" == -* ]] && return 0
  [[ -n "$pr_head" ]] && command git merge-base --is-ancestor "$branch" "$pr_head" 2>/dev/null
}

function _gb_cleanup() {
  local mode="$1" target current branch upstream track worktree i
  local -a protected branches worktrees
  local -A pr_heads

  command git rev-parse --git-dir &>/dev/null || return
  command git fetch --prune origin || return
  command git worktree prune
  current="$(command git branch --show-current)"

  if [[ "$mode" != force ]]; then
    target="$(_gb_target "$2")" || return
    (( $+commands[gh] )) && pr_heads=(${(f)"$(command gh pr list --state merged --limit 1000 --json headRefName,headRefOid --jq 'reverse | .[] | .headRefName, .headRefOid' 2>/dev/null)"})
  fi
  protected=($_gb_protected ${target#*/})

  command git for-each-ref refs/heads/ --format='%(refname:short):%(upstream:lstrip=3):%(upstream:track):%(worktreepath)' |
  while IFS=: read -r branch upstream track worktree; do
    [[ "$branch" == "$current" ]] && continue
    (( ${protected[(Ie)$branch]} )) && continue
    [[ "$mode" == merged || "$track" == "[gone]" ]] || continue
    [[ "$mode" == force ]] || _gb_is_merged "$branch" "$target" "${upstream:+${pr_heads[$upstream]}}" || continue
    branches+=("$branch")
    worktrees+=("$worktree")
  done

  (( $#branches )) || { echo "No branches to delete."; return 0 }
  if [[ "$mode" == force ]]; then
    for i in {1..$#branches}; do
      print -r -- "  $branches[i]${worktrees[i]:+  (worktree $worktrees[i])}"
    done
    read -q "?Force-delete these $#branches branches? [y/N] " || { echo; return 1 }
    echo
  fi

  for i in {1..$#branches}; do
    if [[ -n "$worktrees[i]" ]]; then
      command git worktree remove -- "$worktrees[i]" || continue
    fi
    command git branch -D -- "$branches[i]"
  done
}

unalias gbgd gbgD 2>/dev/null
function gbdr() { _gb_cleanup merged "$1" }
function gbgd() { _gb_cleanup gone "$1" }
function gbgD() { _gb_cleanup force }
compdef _git gbdr=git-branch gbgd=git-branch gbgD=git-branch

# DISABLE_MAGIC_FUNCTIONS="true"

typeset -U path PATH

# Go
export GOPATH="$HOME/go"
[[ -d "$GOPATH/bin" ]] && export PATH="$GOPATH/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ -d "$PNPM_HOME" ]] && export PATH="$PNPM_HOME:$PATH"
[[ -d "$PNPM_HOME/bin" ]] && export PATH="$PNPM_HOME/bin:$PATH"

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Added by Antigravity
export PATH="/Users/tommyliu/.antigravity/antigravity/bin:$PATH"

# mise
eval "$(mise activate zsh)"
