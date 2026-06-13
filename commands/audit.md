---
description: Audit the codebase for production readiness
argument-hint: '[optional path or area to focus]'
allowed-tools: Read, Grep, Glob, Bash(ls*), Bash(cat*), Bash(git*)
---

Audit the codebase for production readiness. Goal: a prioritized, evidence-backed report — not fixes.

## Scope

Default to the whole repo. If `$ARGUMENTS` names a path or area, focus there. First map the stack and entry points (manifests, build config, framework) so findings are grounded in what's actually here.

## What to look for

- **Critical bugs** — logic errors, race conditions, unhandled errors, data loss, crashes.
- **Security** — injection, auth/authz gaps, secrets in code, unsafe deserialization, missing input validation.
- **Memory & resources** — leaks, unclosed handles/connections, unbounded growth, missing cleanup.
- **Performance** — N+1 queries, blocking I/O on hot paths, needless allocations, missing indexes/caching.
- **Refactor potential** — duplication, dead abstractions, oversized functions, tight coupling.
- **Dead weight** — unused dependencies, unreachable/unused code, commented-out blocks.
- **Production gaps** — missing error handling, logging, config/env validation, health checks, graceful shutdown.
- **CLAUDE.md** — if a `CLAUDE.md` (or `AGENTS.md`) exists, check it against the actual code: flag stale instructions (reference removed files/commands/scripts), redundant or duplicated rules, and missing guidance for important setup/build/test/run steps not yet documented.

## Rules

- Verify before claiming. Cite `file:line` for every finding. No speculation — if unsure, mark it as needs-confirmation.
- Distinguish "bug" (wrong behavior, prove it) from "improvement" (preference).
- For unused deps/code, confirm with a search across the repo before flagging — re-exports, dynamic imports, and config-referenced names are easy to miss.
- Do not change code. Do not commit. Report only.

## Output

Markdown report grouped by severity (Critical → Major → Minor → Nits), then a separate Cleanup section (unused deps/code) and Improvements section. Each finding: one line `severity` + `file:line` + problem + suggested fix. End with a short "Production readiness" verdict (ready / blockers remain) listing the must-fix items.

Focus: $ARGUMENTS
