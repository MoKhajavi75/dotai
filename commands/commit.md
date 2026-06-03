---
description: Create atomic git commits
argument-hint: '[optional scope or focus]'
allowed-tools: Bash(git*), Read, Edit
---

Create atomic git commits from the current changes.

- First inspect `git status` and `git diff` to understand every change.
- One logical change per commit; if a file mixes concerns, split it by staging hunks (`git add -p`) or temporarily reverting the other part.
- Conventional Commits, title only — no body.
- Keep the subject ≤50 chars; respect any commitlint config in the repo (allowed types/scopes).
- Do not push. Don't add new changes — only commit what's already there.
- Focus: $ARGUMENTS
