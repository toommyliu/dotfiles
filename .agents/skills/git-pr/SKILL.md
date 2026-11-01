---
name: git-pr
description: Create a pull request or draft its branch, commit message, title, and body. Use when asked to open or preview a PR.
---

# Create a pull request

1. Inspect the repository instructions, working tree, current branch, upstream, commits, and diff against the base branch.

   Read enough recent merged PR history to identify a consistent title convention.

2. Prepare the branch and PR.

   Use the current branch if it already represents the change. Otherwise use `<type>/<short-description>` in lowercase kebab case.

   Follow the repository's PR title convention. If none is consistent, use Conventional Commits. State the change plainly.

   Write the body in one to three sentences: what the PR does, and why if the title does not make it obvious. Leave out anything the title or diff already shows, and how it was tested. Do not use headings.

3. Complete the requested mode.

   For a dry run, make no repository or remote changes. If the PR contains uncommitted changes, use the [`git-commit`](../git-commit/SKILL.md) skill in dry-run mode. Reply with the proposed branch name, commit message, PR title, exact PR body, and any files to attach.

   Otherwise, create or switch branches if needed, then use the [`git-commit`](../git-commit/SKILL.md) skill for any uncommitted changes. Push the branch and create the PR. Read the PR back before reporting its URL.

   Include screenshots only for visual changes, and frame each one on the changed component. End the body with a Before/After table, or one image for new UI. Use only existing screenshots that show the base branch as Before and this branch's final code as After. If none fit, tell the user instead. Reference each file by its local path, such as `![The login error state](./login.png)`.

   To attach files, pass one `--attach <path>` per file to `gh pr create`, `gh pr edit`, or `gh pr comment`. Add alt text for an image with `'<path>#<alt text>'`; video takes no alt text. Only image and video files are supported, each file at most once, and at most 50 per command. Attachment files must stay outside the worktree and are never committed.

   If an attachment fails, `gh pr create` still creates the PR with the attachments that succeeded, exits non-zero, and prints the PR URL. Do not run `gh pr create` again. Retry the failed files with `gh pr edit <url> --attach`, then report any that still fail.
