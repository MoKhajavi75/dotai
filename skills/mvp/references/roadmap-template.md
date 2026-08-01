# ROADMAP.md template

Write this to the project root. It is the single source of truth for phase state.

Keep it short enough that it stays accurate. Prose belongs in the demo notes, not here.

---

```markdown
# Roadmap

**Current phase:** P0 — Skateboard
**Features:** A, B, C

| Phase | Name       | Client gains                             | Status      |
| ----- | ---------- | ---------------------------------------- | ----------- |
| P0    | Skateboard | See the whole product, click every screen | 🚧 current  |
| P1    | Scooter    | Real data that saves                      | ⬜ planned  |
| P2    | Bike       | Team can actually use it                  | ⬜ planned  |
| P3    | Car        | Production ready                          | ⬜ planned  |

---

## P0 — Skateboard 🚧

**Goal:** <one line, in client language>

| Feature | In this phase                | Faked / deferred                    |
| ------- | ---------------------------- | ----------------------------------- |
| A       | List + search, fixture data  | No create/edit — P1                 |
| B       | Charts render fixture totals | Numbers not real — P1               |
| C       | Read-only summary            | No actions — button disabled, P2     |

**Done when:**
- [ ] Every screen reachable from the nav
- [ ] <feature A checkpoint>
- [ ] <feature B checkpoint>
- [ ] <feature C checkpoint>
- [ ] A non-technical person can click through it without getting stuck

---

## P1 — Scooter ⬜

**Goal:** <one line>

| Feature | In this phase | Faked / deferred |
| ------- | ------------- | ---------------- |
| ...     |               |                  |

**Done when:**
- [ ] ...

---

## Faked ledger

Every shortcut currently in the codebase, and the phase that pays it off.

| Shortcut                          | Where                    | Paid off in |
| --------------------------------- | ------------------------ | ----------- |
| Users read from a fixture array   | `src/data/users.ts`      | P1          |
| No auth — session hardcoded       | `src/lib/session.ts`     | P2          |
| Billing "Upgrade" button disabled | `src/routes/billing.tsx` | P3          |

---

## Shipped

| Phase | Shipped    | Demo note                |
| ----- | ---------- | ------------------------ |
| —     | —          | —                        |
```

---

## Rules for maintaining it

- Status markers: `🚧 current`, `✅ shipped YYYY-MM-DD`, `⬜ planned`. Exactly one phase is `🚧`.
- Get dates from `date +%Y-%m-%d`. Never guess them.
- The Faked ledger is append-on-shortcut, remove-on-payoff. Add the row the moment you write the shortcut, not at the end of the phase.
- Later phases can stay coarse. Only the current and next phase need a filled-in feature table — detail beyond that gets rewritten by client feedback anyway.
- When a phase ships, add its row to Shipped with a one-line version of the demo note.
