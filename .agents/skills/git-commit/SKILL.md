---
name: git-commit
description: Turn one coherent set of local changes into a clear Git commit. Use when the user asks to commit changes or create a commit.
---

# Git Commit

Inspect `git status` and the relevant diff to understand the change’s intent and risk.

1. Commit exactly one coherent change. Use an explicitly named scope; otherwise prefer staged changes. If neither applies, stage the smallest coherent set. Preserve unrelated staged and unstaged changes.

2. If the candidate scope mixes unrelated work, do not commit it as one unit; propose the smallest split.

3. Match the repository’s recent commit style. If no clear convention exists, use Conventional Commits. Keep the subject concise and human-readable; add a body only when it adds important intent or risk.

4. Create the commit and report its hash and subject.