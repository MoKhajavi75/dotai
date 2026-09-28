# Skills

My own skills. One folder each, `SKILL.md` inside.

## Install One

```bash
pnpx skills add MoKhajavi75/dotai --skill NAME -a claude-code -y       # one
pnpx skills add MoKhajavi75/dotai --skill NAME -a claude-code -y -g    # one (global)
```

## Install All

```bash
pnpx skills add MoKhajavi75/dotai -a claude-code -y         # all
pnpx skills add MoKhajavi75/dotai -a claude-code -y -g      # all (global)
```

---

## [`mvp`](./mvp/) — phased delivery

Cuts a feature list into 3–5 phases where **every phase contains every feature** — shallow at first, deeper each round. Skateboard, then scooter, then bike, then car. Prevents the "one feature finished, the rest missing" delivery a client can't react to, and makes progress visible every phase instead of once at the end.

```
/mvp plan     turn a feature list into a phased ROADMAP.md
/mvp status   current phase, what's left, what's faked
/mvp build    implement the current phase — hard stops at the phase boundary
/mvp next     close the phase, promote and re-scope the next one
/mvp demo     client-facing note for the current phase
```

State lives in `ROADMAP.md` in the project root, with a ledger of every shortcut taken and the phase that pays it off. Manual-only — `disable-model-invocation`, so it never fires on its own.

## [`audit`](./audit/) — production readiness

Principal-engineer review before launch: bugs, security holes and data leaks, DB schema and index problems, performance, reliability, concurrency, observability, architecture, and dead weight. Traces the hot paths end to end, then proposes concrete fixes, including DB migrations with DDL, zero-downtime notes, and the `EXPLAIN` to verify them. Asks before spawning parallel agents on big repos. Reports only, never fixes. Every finding cites `file:line`; ends with a verdict and a fix order.

```
/audit [optional path or area]
```

## [`commit`](./commit/) — atomic commits

Splits the working tree into one logical change per commit, staging hunks where a file mixes concerns, ordered so each commit builds on its own. Conventional Commits, ≤50 char subject, plus a short body explaining why only when the diff can't. Matches repo history and commitlint config, stops on secrets or debug leftovers, never skips hooks, never pushes.

```
/commit [optional scope or focus]
```

## [`estimate`](./estimate/) — VPS sizing

Infers the stack from the codebase, asks only what it can't determine, then outputs a RAM/CPU table per concurrency tier plus the formula it used.

```
/estimate [app or stack description]
```
