---
name: commit
description: Create atomic git commits with clear subjects and a short why-focused body when needed
argument-hint: '[optional scope or focus]'
allowed-tools: Bash(git*), Read, Write
---

Create atomic git commits from the current changes. Write history the way a principal engineer does: each commit is one reviewable, revertable change, and its message tells a future reader what changed and why.

## 1. Inspect

- Run `git status`, `git diff`, and `git diff --staged` to understand every change. Read untracked files before deciding on them.
- Run `git log --oneline -15` to match the repo's style (scopes used, casing, tense).
- Check for commitlint config (`commitlint.config.*`, `.commitlintrc*`, `commitlint` key in `package.json`) and follow its allowed types, scopes, and length limits.
- If changes are already staged, treat them as the user's intended first commit. Mention it if they mix concerns.

## 2. Guard

Stop and ask before committing any of these. Never commit them silently:

- Secrets: `.env*` with values, keys, tokens, credentials, private certs.
- Build output, dependency folders, OS or editor junk, large binaries that belong in `.gitignore`.
- Debug leftovers in the diff: `console.log`, `debugger`, `print(` added for debugging, `.only(` in tests, commented-out blocks.
- Merge conflict markers.
- Untracked files unrelated to the other changes. Leave them out and mention them.

## 3. Split

- One logical change per commit: a feature, a fix, a refactor, a dependency bump, a formatting pass. Unrelated changes never share a commit, even in the same file.
- Refactors and formatting go in their own commits, separate from behavior changes.
- Order commits so each one builds and passes on its own (for example the migration or shared helper before the code that uses it).
- If one file mixes concerns, stage hunks without interactive mode: write the hunks you want to a patch file in a temp or scratchpad directory, then `git apply --cached <patch>`. Verify with `git diff --staged`. Never discard or revert the user's work to split it.
- Do not over-split. A feature plus its tests plus its docs is one commit.

## 4. Message

Conventional Commits: `type(scope): subject`.

**Type:** `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `chore`, `style`, `revert`. Pick by effect on users, not by file type.

**Subject:**

- Max 50 characters, unless commitlint allows more.
- Imperative mood, lowercase after the colon, no trailing period: `fix(auth): reject expired refresh tokens`.
- Says what changed in behavior, not which files were touched.
- Scope only if the repo uses scopes; reuse existing scope names.

**Body (only when it adds something):**

Most commits need no body. Add one when a reviewer or future reader would ask "why?" and the diff cannot answer:

- The reason or problem: bug symptom, incident, constraint, requirement.
- A non-obvious decision or trade-off, and the alternative rejected.
- Side effects, migration steps, or follow-up needed.

Rules:

- Blank line after the subject. Wrap at 72 characters.
- 1 to 4 lines, or a few short bullets. Never an essay.
- Why over what. Never restate the diff, list files, or narrate ("This commit...", "Updated X to Y").
- Skip the body for self-explanatory changes: typos, dependency bumps, renames, docs, formatting.

**Footer:**

- Breaking change: add `!` after the type or scope, plus `BREAKING CHANGE: <what breaks and how to migrate>`.
- Issue refs (`Closes #123`, `Refs ABC-45`) only when known from the branch name, the conversation, or the diff. Never invent them.

Example:

```
fix(orders): prevent double charge on retry

Payment provider retries webhooks on timeout, and the handler
charged again on each delivery. Dedupe on the provider event ID
before charging.
```

Commit with `git commit -m "<subject>" -m "<body>"` or a heredoc so newlines survive.

## 5. Hooks and safety

- Never use `--no-verify`. If a hook fails, report the error and stop. Do not change code to satisfy it unless asked.
- If a hook reformats files, re-stage only those files and commit again.
- Do not push, amend, rebase, reset, or force anything.
- Do not add new changes. Only commit what is already in the working tree.

## 6. Report

List the commits made (`short hash  subject`) and anything left uncommitted, with the reason.

Focus: $ARGUMENTS
