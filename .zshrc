# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

function _gb_is_merged() {
  local branch="$1" target="$2" upstream="$3" merged="$4" merge_base synthetic oid

  command git merge-base --is-ancestor "$branch" "$target" && return 0

  merge_base="$(command git merge-base "$target" "$branch")" || return 1
  synthetic="$(command git commit-tree "$(command git rev-parse "$branch^{tree}")" -p "$merge_base" -m _)" || return 1
  [[ "$(command git cherry "$target" "$synthetic")" == -* ]] && return 0

  [[ -n "$upstream" && -n "$merged" ]] || return 1
  oid="$(print -r -- "$merged" | awk -v u="$upstream" '$1 == u { print $2; exit }')"
  [[ -n "$oid" ]] && command git merge-base --is-ancestor "$branch" "$oid" 2>/dev/null
}

function _gb_delete_branch() {
  local branch="$1" worktree="$2"
  if [[ -n "$worktree" ]]; then
    command git worktree remove -- "$worktree" || return
  fi
  command git branch -D -- "$branch"
}

function _gb_cleanup() {
  local gone_only="$1" target_ref current_branch branch upstream track worktree merged
  local -a protected_branches

  target_ref="$(_gb_remote_merged_setup "$2")" || return
  current_branch="$(command git branch --show-current)"
  protected_branches=(main master trunk develop development dev devel "${target_ref#*/}")
  command git worktree prune
  (( $+commands[gh] )) && merged="$(command gh pr list --state merged --limit 1000 --json headRefName,headRefOid --jq '.[] | "\(.headRefName) \(.headRefOid)"' 2>/dev/null)"

  command git for-each-ref refs/heads/ --format='%(refname:short):%(upstream:lstrip=3):%(upstream:track):%(worktreepath)' |
  while IFS=: read -r branch upstream track worktree; do
    [[ -n "$gone_only" && "$track" != "[gone]" ]] && continue
    [[ -z "$branch" || "$branch" == "$current_branch" ]] && continue
    (( ${protected_branches[(Ie)$branch]} )) && continue
    _gb_is_merged "$branch" "$target_ref" "$upstream" "$merged" && _gb_delete_branch "$branch" "$worktree"
  done
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
function gbdr() { _gb_cleanup "" "$1" }
compdef _git gbdr=git-branch

# Make the stock "gone branch delete" alias squash/rebase-aware.
unalias gbgd 2>/dev/null
function gbgd() { _gb_cleanup 1 "$1" }
compdef _git gbgd=git-branch

unalias gbgD 2>/dev/null
function gbgD() {
  local current_branch branch track worktree i
  local -a branches worktrees

  command git fetch --prune || return
  current_branch="$(command git branch --show-current)"

  command git for-each-ref refs/heads/ --format='%(refname:short):%(upstream:track):%(worktreepath)' |
  while IFS=: read -r branch track worktree; do
    [[ "$track" == "[gone]" && "$branch" != "$current_branch" ]] || continue
    branches+=("$branch")
    worktrees+=("$worktree")
  done

  (( $#branches )) || { echo "No gone branches."; return 0 }
  for i in {1..$#branches}; do
    print -r -- "  $branches[i]${worktrees[i]:+  (worktree $worktrees[i])}"
  done
  read -q "?Force-delete these $#branches branches? [y/N] " || { echo; return 1 }
  echo

  for i in {1..$#branches}; do
    _gb_delete_branch "$branches[i]" "$worktrees[i]"
  done
}
compdef _git gbgD=git-branch

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
