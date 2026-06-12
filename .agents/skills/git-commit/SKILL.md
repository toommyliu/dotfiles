---
name: git-commit
description: Draft concise git commit messages from local changes, following the repository's existing commit convention when discoverable and falling back to Conventional Commits otherwise. Use when the user asks for a commit message, wants staged changes committed, wants the current working directory committed, asks to stage and commit a coherent change, wants a commit message copied to the clipboard, or wants a semantic branch name for local git work.
---

# Git Commit

## Core Behavior

Help the user turn local git changes into a clear commit.

Follow the repository's convention first. Inspect recent commits before drafting:

```bash
git log -8 --pretty=format:%s
```

If recent commits show a clear style, match it. If the history is mixed or unhelpful, use Conventional Commits:

```text
type(scope): imperative description

- optional short body bullet
- optional second bullet
```

Fallback rules:

- Use `feat`, `fix`, `docs`, `style`, `refactor`, `test`, or `chore`.
- Keep the subject at 72 characters or fewer.
- Make the description imperative and do not add a trailing period.
- Include a body only when it adds useful context, risk, or follow-up detail.
- Capture the primary user-visible or developer-visible change, not every file touched.

## Workflow

1. Confirm the repository state:

```bash
git status --short
git branch --show-current
```

If the directory is not a git repository or there are no changes, report that and stop.

2. Choose the source of truth:

- If staged changes exist, draft from staged changes by default.
- If no staged changes exist, inspect the working tree. If the user asked to commit, stage only the coherent requested change before committing.
- If both staged and unstaged changes exist, treat staged changes as the intended commit. Mention unstaged changes remain outside the commit unless the user explicitly wants them included.

3. Inspect enough context to write the message:

```bash
git diff --cached --stat
git diff --cached --name-status
git diff --cached --check
git diff --cached
```

For unstaged changes, use the same commands without `--cached`. For very large diffs, read stats, file names, and representative hunks instead of loading everything.

4. Draft the message. If the user asked for a branch name, also suggest a short semantic fragment such as `fix-login-redirect` or `feat-export-csv`.

5. Copy the final message to the clipboard when useful or requested:

```bash
printf '%s' "$COMMIT_MESSAGE" | pbcopy
```

Use `pbcopy` on macOS. On other platforms, use the available clipboard command only if obvious; otherwise skip clipboard copying and say so.

6. Commit only when the user asked for a commit or clearly implied they want one. Prefer a temporary message file so shell quoting cannot corrupt the commit:

```bash
git commit -F /tmp/commit-message.txt
```

After committing, show the short commit hash and subject:

```bash
git log -1 --oneline
git status --short
```

## Staging Guidance

When the user asks to commit the working directory and nothing is staged:

- Inspect `git status --short` and the diff before staging.
- Stage the smallest coherent set of files for the requested change.
- Use `git add <paths>` for explicit files. Use `git add -A` only when all changes clearly belong to one commit.
- Do not stage secrets, local config, build outputs, dependency folders, or unrelated edits.
- If unrelated changes are mixed into the same file and cannot be cleanly separated, ask before proceeding.

## Message Heuristics

Choose the type by intent:

- `feat`: new user-facing or developer-facing capability
- `fix`: bug fix or corrected behavior
- `docs`: documentation-only change
- `style`: formatting or presentation change without behavior change
- `refactor`: code structure change without intended behavior change
- `test`: test-only change
- `chore`: maintenance, config, dependencies, tooling

Use a scope when it makes the message clearer, such as `auth`, `api`, `ui`, `deps`, or a package name. Omit the scope when it would be vague.

Good examples:

```text
fix(auth): preserve redirect after login
feat(export): add CSV download option
refactor(api): simplify pagination parsing
test(parser): cover quoted delimiter cases
chore(deps): update lint tooling
```

Avoid:

```text
updated files
fix: bug fixes
feat(app): add changes.
```
