---
name: mvp
description: Phased delivery — ship a project in demoable horizontal slices (skateboard → scooter → bike → car), every phase containing every feature, shallow first and deeper each round.
argument-hint: '[plan|status|build|next|demo] [feature list or notes]'
disable-model-invocation: true
---

# MVP — horizontal slice delivery

Ship the whole product shallow, then deepen it. Never ship one feature complete while others don't exist.

The reference image: skateboard → scooter → bike → motorcycle → car. Each step is a working vehicle the client can ride and react to. The failure mode is the bottom row: wheel → axle → chassis → car. Nothing rideable until the end.

## Modes

Read the first word of `$ARGUMENTS`:

| Mode     | Does                                                                    |
| -------- | ----------------------------------------------------------------------- |
| `plan`   | Turn a feature list into a phased `ROADMAP.md`.                          |
| `status` | Report current phase, remaining scope, and the faked ledger.             |
| `build`  | Implement the current phase — and nothing beyond it.                     |
| `next`   | Close the current phase, promote to the next, re-scope it.               |
| `demo`   | Write the client-facing note for the current phase.                      |

No mode given: if `ROADMAP.md` is missing → `plan`. Otherwise → `status`.

`ROADMAP.md` lives in the project root and is the single source of truth. Read it before every mode except `plan`. Never guess the current phase — read it.

## plan

1. Collect the feature list from `$ARGUMENTS`, the conversation, or by asking. Also inspect the codebase (manifests, existing routes/screens) so the plan fits what's actually here.
2. Ask only what you can't infer: who the user is, what the client most wants to see first, delivery cadence, any hard constraint (must use X DB, must deploy to Y).
3. Read `references/slicing.md` and cut phases with it.
4. Write `ROADMAP.md` using `references/roadmap-template.md`. Get the date from `date +%Y-%m-%d` — do not guess it.
5. Show the phase table and stop. Do not start building. Let the user approve or re-cut.

Aim for 3–5 phases. More than 5 means the slices are too thin; fewer than 3 means P0 is doing too much.

## build

Implement **only** the current phase's scope.

Hard rules:

- **Hard stop at the phase boundary.** If the request belongs to a later phase, refuse, name the phase that owns it, and offer `/mvp next`. This applies to trivial-looking additions too — "while I'm here" is how the discipline dies.
- If the request is genuinely missing from the roadmap, add it to the phase where it belongs, say so, then continue with the current phase.
- **Record every shortcut immediately** in the Faked ledger in `ROADMAP.md` — hardcoded data, skipped validation, stubbed endpoint, disabled button. A shortcut not written down is a bug in a later phase.
- **Do not over-engineer early phases.** P0 gets no abstraction layers, no generic config system, no DB when a JSON file works, no state library when props work. Deleting a P0 shortcut later is cheap; unwinding premature architecture is not.
- **Deferred stays visible.** Ship the nav item, the tab, the button — disabled, with a plain label like "Coming in phase 2". The client should see the whole shape of the car from the skateboard.
- Phase is done when every feature in it is clickable end-to-end by a non-technical person. Not when the code is good.

After building, update `ROADMAP.md`: tick the done items, fill the Faked ledger.

## status

Print, from `ROADMAP.md`: current phase and its goal, what's done vs remaining in it, the full Faked ledger, and the one-line goal of the next phase. Short. No re-planning.

## next

1. Verify the current phase is actually demoable — every feature reachable, no dead links. If not, list the gaps and stop.
2. Mark the phase shipped with today's date (`date +%Y-%m-%d`).
3. Re-scope the next phase before starting it. Client feedback and what you learned outrank the original plan — moving an item between phases is normal and expected. Say what you changed and why.
4. Set the current-phase marker.

## demo

Write a short client-facing note for the current phase. Plain language, no jargon, no file names, no framework names.

Shape:

- **What you can do now** — 2–5 bullets, each an action the client can perform, in their words.
- **What's still simple on purpose** — honest list of the shortcuts that are visible to them, each with the phase that fixes it. E.g. "Uses sample data — connects to your real data in phase 2."
- **Next up** — one line on the next phase.

Be honest about limitations. Never present faked data or a stubbed integration as finished. The point is to show steady, visible progress every phase, not to hide the seams — a client who discovers a hidden seam stops trusting the demos.

## Anti-patterns

Reject these when planning or building:

- **Complete one feature first.** The bottom row of the picture. Every phase touches every feature.
- **Infrastructure-only phase.** "P0: set up the DB, auth, and CI." Nothing to demo. Infra rides along inside a feature phase.
- **Backend-first phase.** An API with no screen is a wheel.
- **Design system first.** Build screens; extract components in a later phase once they repeat.
- **Real auth in P0.** Fake the session unless auth is itself one of the product's features.
- **Deep in one dimension.** Full validation and error recovery on P0 while there's no persistence yet.

See `references/slicing.md` for the depth ladder and the per-dimension rules.
