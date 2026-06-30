---
id: inbox_plan_gate
created: 2026-06-30
status: queued
---

# Plan — Inbox plan-gate: heft decides the plan file, not the command (`inbox_plan_gate`)

## Problem

`/inbox` and plan-mode + `/inbox` produce **different artifact sets** for the same idea:

| | plain `/inbox` | plan-mode + `/inbox` |
|---|---|---|
| roadmap entry | yes, thin nerd line | yes |
| `docs/plans/<id>.md` | **never** | yes, full spec |
| nerd line | inline approach | pointer → plan file |

The command you happen to type decides whether a durable plan exists. That's the inconsistency.
CLAUDE.md already says "anything bigger than a one-liner gets a plan file" — the rule exists, inbox
just never applies it. Big brain-dumps (e.g. "build portfolio grid" — a vanilla-vs-island decision)
get buried in a fat `> nerd:` line instead of a real plan.

## Decisions (this is what was settled)

1. **Heft, not command, decides the plan file.** Bake the plan-decision into inbox itself; plan-mode
   becomes optional *richness*, not a gate. The two flows then converge.

2. **Per-item heft test** (run in inbox's classify step, each item judged independently):
   - **trivial one-liner** (e.g. "header text red") → nerd line only, **no plan file**.
   - **complex** → `docs/plans/<id>.md` **always**, nerd line flips to a pointer
     (`> nerd: … — see docs/plans/<id>.md`).
   - "Complex" triggers: multi-step, **or** a build-approach decision (vanilla vs island, schema
     shape, new collection), **or** needs investigation.

3. **Recommend + create by default, opt-out explicit.** For a complex item, inbox creates the plan by
   default; it does **not** silently skip it. The user can opt out per-item with an explicit
   "no plan" — friction lands on the refuser, not on the default.

4. **Rejected: auto-enter plan-mode on bare `/inbox`.** Technically possible (`EnterPlanMode` tool),
   but wrong tool for the goal — forcing the interactive plan-mode round-trip on a text change buys
   nothing (no design decision to make) and costs a full back-and-forth. Plan-mode is for *deciding*,
   not for *logging*. See [[timeline_provenance_stamps]] for the logging half.

5. **Do NOT blanket-create for trivial items.** A plan file per text change = roadmap clutter +
   token noise that drowns the real plans. The heft test is the filter; keep it.

## Plan-file shape (when created)

Stub is enough at inbox time — `/forge`/`/fire` fills the rest:

```markdown
---
id: <id>
created: YYYY-MM-DD
status: queued
---
# Plan — <title> (<id>)
## Context
<brain-dump pasted verbatim>
## Steps
_TBD — expanded at build time._
```

## Steps

1. Edit `inbox` SKILL.md classify step: add the per-item heft verdict (trivial vs complex) and the
   "complex → create plan stub + flip nerd line to pointer, default-on, explicit opt-out" rule.
2. Add a heft-test column to the inbox proposal table so the verdict is visible before write.
3. Confirm the app CLAUDE.md "bigger than one-liner → plan file" rule and the `docs/plans/<id>.md`
   path are consistent with what inbox writes.
4. Pairs with [[timeline_provenance_stamps]] (the date log) and [[history_crisscross]] (the reader).
