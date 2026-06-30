---
id: timeline_provenance_stamps
created: 2026-06-30
status: queued
---

# Plan — Timeline provenance stamps: log EVERY item, dated (`timeline_provenance_stamps`)

## Problem / goal

Want to cross-reference *when* work happened: an item inboxed Jun 30 might only ship Aug 12. Today
there is no dated trail — `docs/plans/<id>.md` has no metadata, archive entries carry no inbox date.
Cannot answer "when did we decide / change / ship X?".

## Decisions (this is what was settled)

1. **Log ≠ plan. Separate the two ideas.** The user's instinct was "plan everything, log even a text
   change." What that actually needs is **log** everything, not **plan** everything:
   - **log** = timeline (dates) → wanted on **every** item, text changes included. Cheap.
   - **plan** = design doc (vanilla vs island, schema) → heft-gated, complex only.
     See [[inbox_plan_gate]].
   To answer "when did the header change?" you need a *dated record*, not a design rationale.

2. **Dated frontmatter, stamped across the lifecycle:**
   ```
   ---
   id: home_header_color
   inboxed: 2026-06-30
   fired:   2026-08-10
   shipped: 2026-08-12
   plan:    none        # or docs/plans/<id>.md
   ---
   ```
   - `/inbox` writes `inboxed:`
   - `/fire` writes `fired:`
   - `/ship` writes `shipped:`
   Lives on the roadmap item **and** carries into the archive entry, so every item — trivial or not —
   is traceable across the inbox→ship gap without dragging it through plan-mode.

3. **Filename stays the id, never date-prefixed.** The id is the `/fire` handle: stable, greppable,
   never reused. Dates live in frontmatter; sort by reading `created:`/`inboxed:`, not by filename.

## Steps

1. Add the timeline-frontmatter rule to the app CLAUDE.md "Workflow conventions" block (single source
   of truth) — fields + which skill stamps which.
2. Teach `inbox` to stamp `inboxed:`, `fire` to stamp `fired:`, `ship` to stamp `shipped:` (and copy
   the stamps into the archive entry on ship).
3. Decide carrier: frontmatter on the roadmap item vs a sidecar — frontmatter preferred (travels with
   the item, survives /clear, lives in git).
4. Powers [[history_crisscross]] (the reader). Independent of [[inbox_plan_gate]] but ships well with it.
