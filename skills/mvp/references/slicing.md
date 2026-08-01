# Slicing rubric

How to cut a feature list into phases that are each demoable.

## The one rule

**Every phase contains every feature.** Depth changes between phases, never the feature set.

If the project is "dashboard with A, B, C", then P0 has A, B, and C — all shallow. Not "P0 = A done properly".

A feature that literally cannot appear yet (it depends on data that doesn't exist) still appears — as a screen with sample data, or as a visible disabled entry point. It never disappears.

## Depth dimensions

A phase is a level across these dimensions. Raise all of them roughly one notch per phase. Never max one dimension early.

| Dimension        | L0 (skateboard)          | L1 (scooter)              | L2 (bike)                      | L3 (car)                          |
| ---------------- | ------------------------ | ------------------------- | ------------------------------ | --------------------------------- |
| **Data**         | hardcoded in component   | seed file / fixtures      | real CRUD                      | live, synced, derived             |
| **Persistence**  | none, resets on reload   | localStorage / JSON file  | real DB                        | migrations, backups, integrity    |
| **Auth**         | none, or a fake session  | single hardcoded login    | real auth, one role            | roles, permissions, invites       |
| **Validation**   | happy path only          | required fields           | full rules + server-side       | recovery, retries, conflicts      |
| **States**       | content state only       | + empty, + loading        | + error, + edge cases          | + offline, + partial failure      |
| **Visual**       | layout, default styling  | on-brand, desktop-correct | responsive, dark mode          | motion, a11y, polish pass         |
| **Scale**        | 5 rows                   | pagination                | indexes, caching               | tuned for real volume             |
| **Integrations** | stubbed, returns fixture | sandbox / test keys       | real keys, happy path          | webhooks, retries, reconciliation |

You don't need every dimension at exactly the same level. You do need a reason when one jumps ahead.

## Cutting the phases

1. **List the features.** One line each, in the client's words.
2. **For each feature, write its L0.** The thinnest version that a person can still click through and understand. This is the hardest step and the whole value of the method.
3. **P0 = all the L0s + navigation between them.** Ask: can a non-technical person open this and see the shape of the finished product? If no, P0 is too thin. Can they do real work with it? If yes, P0 is too fat.
4. **Each later phase = raise the dimensions one notch across all features.** Name each phase by what the client gains, not by what you'll code.
5. **Sanity check:** delete any phase from the middle. Do the remaining ones still each stand alone as a demo? If a phase only makes sense sandwiched between two others, it isn't a slice.

## Sizing

- 3–5 phases total. More means the slices are too thin to be worth a demo.
- Each phase should be roughly one delivery cadence — whatever interval you actually show the client.
- P0 should be the shortest phase. If P0 is the longest, the L0s aren't thin enough.

## Ordering later phases

After P0, order by **what changes the client's mind**, not by technical dependency. The thing they're most uncertain about — the thing they'll want changed — goes next, while changing it is still cheap.

Technical dependency only forces order when it's genuine. "We should do the DB before the UI" is almost never genuine; the UI can read a fixture.

## Where to fake

Fake anything that's expensive to build and cheap to imitate at the demo boundary:

- **Fake it:** auth sessions, third-party APIs, emails/notifications, background jobs, payments, file processing, search ranking, permissions.
- **Don't fake it:** the core interaction the product exists for. If it's a dashboard, the charts render from data. If it's a form builder, the form builds. The one thing that makes it *this* product is real from P0.

Every fake goes in the Faked ledger in `ROADMAP.md` the moment you make it, with the phase that replaces it.

## Worked example

"Admin dashboard: (A) user management, (B) analytics, (C) billing."

- **P0 — Skateboard.** All three screens, real navigation. Users list from a fixture with a working search box. Analytics charts rendering fixture numbers. Billing showing a fake current plan. No login, no DB, nothing saves. *Client can see the whole product and tell you the analytics page is wrong.*
- **P1 — Scooter.** Real DB + CRUD for users. Analytics computed from the real user table. Billing still a fake plan but the plan tiers are real. Single hardcoded login. *Client can add a real user and watch analytics move.*
- **P2 — Bike.** Real auth with one role. Validation and error states everywhere. Billing wired to Stripe sandbox. Responsive. *Client can hand it to a colleague.*
- **P3 — Car.** Roles and permissions. Real payments. Pagination and caching for real volume. Polish pass. *Ship.*

Note what never happens: a phase where only user management exists.
