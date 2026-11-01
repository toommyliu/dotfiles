---
name: git-commit
description: Create a Git commit or draft its message. Use when asked to commit changes or preview a commit.
---

# Create a commit

1. Inspect the repository instructions, working tree, staged changes, and unstaged changes.

   Read enough recent commit history to identify a consistent message convention. Use the user's request, and conversation context if available, to identify the intended changes. Keep the commit coherent and preserve unrelated work, including its staging state.

2. Write the commit message.

   Follow the repository's convention for the subject line. If none is consistent, use Conventional Commits:

   ```text
   <type>(<optional scope>): <short description>
   ```

   State the change plainly. Write only the subject line unless the user asks for a body.

3. If the user requests a dry run, make no repository changes and reply with the complete commit message.

   Otherwise, stage the intended changes, inspect the staged diff, and create the commit. Verify the commit before reporting its hash and message. If there are no intended changes to commit, report that instead of creating an empty commit.
