---
name: git-pr
description: Prepare local git changes for a pull request by drafting or creating a commit, choosing a conventional branch name, pushing the branch, and optionally opening a PR. Use when the user asks to make a PR, open a pull request, prepare changes for review, push a branch with a PR, draft PR text, or do a dry run for publishing local changes.
---

# Git PR

## Core Behavior

Help the user turn local changes into a branch, commit, and pull request.

Default to a dry run unless the user clearly asks to create, open, publish, or push the PR. In a dry run, inspect the repository and present the proposed branch name, commit message, PR title, PR body, files to include, and exact commands that would run.

When actually opening a PR, default to draft unless the user asks for a non-draft or ready-for-review PR.

## Repository Conventions

Inspect recent history before naming things:

```bash
git log -12 --pretty=format:%s
git branch --show-current
git remote -v
```

Use the repository's visible commit and PR title style when it is clear. For branch names, prefer a conventional `type/short-description` fragment unless the repository has a strong branch naming requirement.

- Branch name: use `type/short-description`, such as `feat/export-csv`, `fix/login-redirect`, or `chore/update-lint`.
- Commit message: match repo convention, otherwise use Conventional Commits.
- PR title: match repo convention, otherwise use Conventional Commits.

Conventional Commit fallback:

```text
type(scope): imperative description
```

Use `feat`, `fix`, `docs`, `style`, `refactor`, `test`, or `chore`. Keep commit subjects and PR titles concise, ideally 72 characters or fewer.

## Workflow

1. Confirm repository state:

```bash
git status --short
git branch --show-current
git remote -v
```

Stop if the directory is not a git repository or there are no changes and no existing branch work to publish.

2. Inspect the change:

```bash
git diff --stat
git diff --name-status
git diff --check
git diff
```

If staged changes exist, also inspect:

```bash
git diff --cached --stat
git diff --cached --name-status
git diff --cached --check
git diff --cached
```

For large diffs, use stats, file names, and representative hunks instead of loading everything.

3. Choose what to include:

- If staged changes exist, treat them as the intended commit.
- If nothing is staged and the user asked to publish current work, stage the smallest coherent set of files.
- Use `git add <paths>` for explicit files. Use `git add -A` only when all changes clearly belong together.
- Do not stage secrets, local config, build outputs, dependency folders, or unrelated edits.
- If unrelated changes are mixed into the same file and cannot be cleanly separated, ask before proceeding.

4. Prepare names and text:

- Branch: `type/short-description` unless the repo clearly requires another branch style.
- Commit: match repo convention, otherwise Conventional Commits.
- PR title: match repo convention, otherwise Conventional Commits.
- PR body: keep it useful and short.

Suggested PR body:

```markdown
## Summary
- ...
- ...

## Testing
- ...
```

Use `Not run (reason: ...)` in Testing when no verification was performed. In all generated text, including commit messages, PR titles, PR bodies, testing notes, and dry-run summaries, mention repository files with paths relative to the repository root. Do not include absolute paths from the local machine such as `/Users/...`, `/tmp/...`, or workspace-specific checkout paths unless the absolute path is itself the subject of the change. Add risk, migration, or screenshot sections only when they are genuinely useful for the change.

5. Copy text to the clipboard when useful or requested:

```bash
printf '%s' "$PR_BODY" | pbcopy
```

Use `pbcopy` on macOS. On other platforms, use the available clipboard command only if obvious; otherwise skip clipboard copying and say so.

6. Create or switch to the branch:

```bash
git switch -c feat/example-change
```

If already on a suitable feature branch, keep using it. If the current branch is a protected or shared base branch such as `main`, `master`, `develop`, or `release/*`, create a new branch before committing.

7. Commit if needed:

```bash
git commit -F /tmp/commit-message.txt
```

Prefer a temporary message file so shell quoting cannot corrupt the message. Skip this step if the branch already contains the intended commit and the user only asked to open a PR.

8. Push and open the PR only when explicitly requested:

```bash
git push -u origin feat/example-change
gh pr create --draft --title "feat(scope): description" --body-file /tmp/pr-body.md
```

Use the repository's existing PR tool if one is obvious. Otherwise prefer `gh` when available. If no PR creation tool is configured, provide the pushed branch name and PR title/body for manual creation.

9. Verify the result:

```bash
git log -1 --oneline
git status --short
gh pr view --web
```

Report the branch, commit hash, PR URL, and whether the PR is draft or ready for review. Mention any unstaged or untracked changes left out.

## Dry Run Output

For dry runs, include:

- Proposed branch name
- Proposed commit message
- Proposed PR title
- Proposed PR body
- Files that would be staged or committed
- Whether the PR would be draft
- Commands that would be run

Do not push, commit, or create the PR during a dry run.
