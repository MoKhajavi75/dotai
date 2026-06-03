---
description: Estimate VPS RAM/CPU for an app
argument-hint: '[app or stack description]'
allowed-tools: Read, Grep, Glob, Bash(ls*), Bash(cat*)
---

Estimate the VPS resources (RAM, CPU cores) needed to run this app.

- First, inspect the codebase to infer the stack and services for yourself — manifests (`package.json`, `go.mod`, `requirements.txt`, etc.), `docker-compose.yml`/`Dockerfile`, and config — so the estimate is grounded in what's actually here.
- Then ask the user only what you still can't determine. Defaults if unanswered:
  - OS: Ubuntu 24
  - Concurrency: ask for expected max concurrent users
  - Ask about the stack/services only if the codebase and `$ARGUMENTS` leave them unclear (e.g. DB, cache, background workers).
- Skip any question you can already answer from the codebase or `$ARGUMENTS`.
- Then output ONLY a short Markdown table sizing it per concurrency tier, plus a one-line rough formula. No long explanation.

Example shape:

| Concurrent users | RAM  | CPU cores |
| ---------------- | ---- | --------- |
| ~100             | 1 GB | 1         |
| ~500             | 2 GB | 2         |
| ~1000            | 4 GB | 2–4       |

Formula: `RAM ≈ base + (users × per_user_MB)` — state the values you assumed.

Focus: $ARGUMENTS
