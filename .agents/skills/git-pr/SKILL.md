---
name: git-pr
description: File a concise pull request. Use when the user asks to create a PR.
---

# Git PR

Help the user turn local changes into a branch, commit, and pull request. Optionally propose a branch name, commit message, PR title, and PR body when a dry-run is requested. Never create a PR when doing a dry-run.

Follow the repository's existing conventions. Look at Git history for examples. If no conventions are clear, use Conventional Commits for commit messages and PR titles, and `type/short-description` for branch names.

If staged changes exist, treat them as the intended target. Otherwise, stage the smallest coherent set of files. PRs should be ready to view, unless explicitly requested otherwise.

## Writing Descriptions

Open the description with a concise, human-readable explanation of the change. Avoid technical jargon, focusing on the purpose and impact of the change.