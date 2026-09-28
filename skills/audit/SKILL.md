---
name: audit
description: Principal-engineer production readiness audit. Finds bugs, security holes and data leaks, DB schema and index problems (with proposed migrations), performance and scaling limits, reliability gaps, and dead weight. Reports only, never fixes.
argument-hint: '[optional path or area to focus]'
allowed-tools: Read, Grep, Glob, AskUserQuestion, Agent, Bash(ls*), Bash(cat*), Bash(git*), Bash(wc*)
---

Audit this codebase the way a principal engineer with 15+ years of production scars would before signing off on a launch. Goal: a prioritized, evidence-backed report with concrete fixes. Not fixes applied.

Ask the questions that engineer asks: what breaks at 10x traffic, what pages someone at 3am, what an attacker with a valid account can reach, what data is lost if this process dies mid-write, and what the next engineer will misunderstand.

## Scope

Default to the whole repo. If `$ARGUMENTS` names a path or area, focus there but still trace its callers and data stores.

## Execution mode (ask first)

Before any deep reading, estimate the size: `git ls-files | wc -l` plus a look at the top-level layout. Then ask the user with `AskUserQuestion`, one question, two options:

- **Single session:** audit everything in this conversation. Slower, uses more of this context, no extra agents.
- **Parallel agents:** spawn read-only subagents, one per lens or per area (for example database, security, performance, reliability), then merge and verify their findings here. Faster on big repos, costs more tokens.

Recommend parallel agents only when the repo is large (roughly 300+ tracked source files) or has several independent services. Never spawn an agent before the user answers. If agents are approved:

- Give each agent the system map from step 1, its lens, the relevant `references/` file, and the Rules section below.
- Agents return findings only, in the compact finding format from Output, with `file:line` evidence. No summaries or prose. They never edit files.
- Re-verify every Critical and Major finding yourself before it goes in the report. Drop duplicates.

## Process

1. **Map the system.** Read manifests, build config, Dockerfile, compose, CI, env examples, and entry points. Write down: languages and frameworks, data stores (DB engine, ORM, cache, queue, object storage), external services, trust boundaries (public HTTP, webhooks, admin, workers, CLI), and how it deploys. Every finding must be grounded in this map.
2. **Find the hot paths.** Identify the 3 to 5 flows that matter most: highest traffic, money or auth involved, or writes to core tables. Trace each end to end (route, handler, service, query, response). Most serious bugs live here.
3. **Sweep the lenses** below. Go deep on hot paths, broad everywhere else.
4. **Verify** every finding against the code before writing it.
5. **Report** in the output format below.

## Lenses

### 1. Correctness

- Logic errors, off-by-one, wrong operator, inverted condition, unhandled `null`/`undefined`/`nil`.
- Swallowed errors (`catch {}`, ignored return values, `_ = err`), unhandled promise rejections, missing `await`.
- Time bugs: timezone-naive timestamps, DST, `Date.now()` in tests, float math on money.
- Partial failure: multi-step writes without a transaction, or DB write plus external call with no compensation.

### 2. Security and data leaks

Read `references/security.md` and apply it. Priorities: authz on every data access (IDOR, tenant isolation), injection, secrets in code or git history, PII in logs and API responses, webhook signature checks, auth token handling. If the `security-audit` skill is installed and the codebase is security-sensitive, recommend it for a dedicated deep review at the end.

### 3. Database and data model

Read `references/database.md` and apply it. Review the schema (migrations, ORM models, raw SQL) against the actual queries in code. Propose concrete schema changes: new or composite indexes, dropped redundant indexes, missing constraints, better types, partitioning or archiving. Every proposal ships with DDL, the query it helps (`file:line`), and a zero-downtime migration note.

### 4. Performance and scalability

- N+1 queries, queries inside loops, ORM lazy loading in serializers or templates.
- Unbounded work: missing pagination, `findAll` without limit, loading whole files or tables into memory.
- Blocking I/O or CPU-heavy work on the request path or event loop (sync crypto, image processing, big JSON parse).
- Missing caching on hot, rarely changing reads. Also the opposite: caches with no invalidation or TTL.
- Chatty external calls that can be batched or parallelized; sequential `await` in loops.
- Frontend when present: bundle size, huge dependencies for small features, unmemoized expensive renders, missing image optimization.

### 5. Reliability and resilience

- Every outbound call (HTTP, DB, cache, queue) has a timeout. Retries use backoff with jitter and a cap, and only on idempotent operations.
- Idempotency for payments, webhooks, and queue consumers (dedupe keys, at-least-once delivery handled).
- Graceful shutdown: drains in-flight requests and jobs, closes pools. Health and readiness checks that test real dependencies.
- Backpressure and limits: request body size, rate limits, queue depth, worker concurrency, connection pool size versus DB `max_connections`.
- Single points of failure, in-memory state that breaks with more than one instance (sessions, locks, cron, rate limiters).

### 6. Concurrency

- Read-modify-write races (balances, counters, stock, "check then insert" uniqueness). Fix with atomic updates, row locks, or unique constraints.
- Shared mutable state across requests, goroutine or thread leaks, missing locks, lock ordering that can deadlock.
- Scheduled jobs that run twice when scaled out.

### 7. Memory and resources

- Leaks: listeners never removed, growing module-level maps or caches with no eviction, timers not cleared.
- Unclosed files, sockets, DB connections, streams; missing `defer`/`finally`/`using`.

### 8. Observability

- Structured logs with request or trace IDs. No secrets or PII in logs.
- Errors reported with context, not just `console.log(e)`. Metrics or at least logs on the hot paths.
- Can an on-call engineer tell from logs alone which user, which request, and which dependency failed?

### 9. Architecture and maintainability

- Layering violations (HTTP handlers running SQL directly across the codebase, business logic in controllers or UI).
- God files and functions, circular dependencies, copy-pasted logic that has already diverged.
- **Reuse opportunities:** repeated logic, queries, validation, or UI blocks (3+ copies, or 2 that must stay in sync) that belong in one shared function, hook, or component. List every location, name the extraction and where it lives. Skip coincidental similarity: code that looks alike but changes for different reasons stays separate.
- Premature abstractions with one implementation; leaky abstractions forcing callers to know internals.
- Config scattered as magic values; no single validated config module.
- Only flag what has a real cost. Taste is not a finding.

### 10. API and contracts

- Inconsistent error shapes, status codes that lie (200 with an error body), missing input validation at the boundary.
- Breaking changes without versioning, no pagination contract, responses exposing internal fields.

### 11. Dependencies and supply chain

- Unused dependencies (verify first), duplicates doing the same job, abandoned or deprecated packages, known-vulnerable versions visible in lockfiles.
- Missing lockfile, floating versions (`*`, `latest`), postinstall scripts from unknown packages.

### 12. Config, build, and deploy

- Env vars read without validation or defaults that are unsafe in production (debug on, permissive CORS).
- Dockerfile: runs as root, no multi-stage build, secrets baked into layers, no `.dockerignore`.
- CI: no tests or lint gate, secrets echoed, deploy without migrations step or rollback path.

### 13. Tests

- Critical paths (auth, payments, core writes) with no tests. Tests that assert nothing or mock the thing under test.
- Do not demand coverage numbers. Name the specific untested risk.

### 14. Dead weight

- Unreachable or unused code, commented-out blocks, stale feature flags, unused env vars, orphaned files.
- Confirm with a repo-wide search first. Re-exports, dynamic imports, reflection, and config-referenced names are easy to miss.

### 15. CLAUDE.md / AGENTS.md

If present, check against the code: stale instructions (removed files, commands, scripts), duplicated or contradicting rules, and missing guidance for important setup, build, test, or run steps.

## Rules

- **Verify before claiming.** Cite `file:line` for every finding. Quote the offending line when it helps. If you cannot prove it, mark it `needs-confirmation` and say what would confirm it.
- **Bug versus improvement.** A bug is wrong behavior you can demonstrate with a concrete input or sequence. Everything else is an improvement.
- **Severity by impact times likelihood:**
  - Critical: exploitable, data loss or corruption, or outage under normal use. Must fix before launch.
  - Major: breaks under realistic load, edge cases, or partial failure. Fix soon.
  - Minor: real but contained cost. Fix when touching the area.
  - Nit: polish.
- **No padding.** Five real findings beat fifty generic ones. Skip anything a linter already enforces.
- **Concrete fixes.** Each fix names the change (code shape, DDL, config value), not "consider improving".
- **Read only.** Never change code, never commit, never run migrations, never connect to a real database or external service. Suggest `EXPLAIN` or other commands for the user to run instead.
- **Say what you could not check** (runtime data, production config, traffic patterns, infra outside the repo).

## Output

Short, dense, complete. Thorough in the audit, brief in the report. Every real finding appears; none gets more words than it needs.

- One finding = one bullet, at most 3 lines: location, problem with its concrete failure, fix. No background essays, no restating the code.
- Group same-root-cause issues into one finding listing every location (`a.ts:10, b.ts:44, c.ts:9`), not one finding per occurrence.
- No filler: no intros, no praise, no "overall the code is well structured", no generic advice that applies to every repo.
- Drop empty sections entirely instead of writing "None found".
- Tables for proposals and cleanup; prose only in the verdict.
- If the report runs long, cut words, not findings. Merge Nits into one line each.

```markdown
# Audit: <repo or area> (<date>, <short commit>)

## Verdict

Ready / Ready with fixes / Blockers remain. 2 to 3 sentences: the biggest risks and why.

## System map

At most 5 lines: stack, data stores, entry points, trust boundaries, hot paths traced.

## Findings

### Critical
- **[C1] <title>** · <lens> · `path/file.ts:42` · Effort S/M/L
  <what breaks and how, one sentence>. Fix: <specific change>.

### Major
### Minor
### Nits

## Database proposals

| # | Change | Why (query `file:line`) | Migration safety | Expected impact |
|---|--------|-------------------------|------------------|-----------------|

Then one SQL block with all the DDL, plus one `EXPLAIN` per proposal to confirm it.

## Cleanup

| Item | Evidence |
|------|----------|

## Strategic improvements

At most 5, one line each: change, problem it solves, effort.

## Not checked

One line per item.

## Fix order

Numbered list of the must-fix items, in the order to do them.
```

Focus: $ARGUMENTS
