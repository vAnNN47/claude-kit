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

## Decisions (this is what was settled — user-final)

1. **The agent decides if a plan is needed — not at all costs, not never.** On bare `/inbox`, inbox
   judges each item: does it actually need a plan? Not every item does; not every item is skipped.
   The judgement is the gate, made by the agent, every time — so the user never has to remember to
   run plan-mode.

2. **Needs-a-plan triggers** (any one → plan): a build-approach decision (e.g. vanilla vs Preact
   island, schema shape, new collection), multi-step work, real ambiguity / needs investigation, or a
   large brain-dump. **No plan** → a clear one-liner with an obvious approach (e.g. "header text red").

3. **If a plan IS needed → inbox enters plan mode itself.** It calls `EnterPlanMode`, **asks the
   clarifying questions**, drafts the plan, then `ExitPlanMode` for approval; on accept it writes
   `docs/plans/<id>.md` and points the nerd line at it. The plan is born *with* its open questions
   answered — that is the whole value.

4. **If no plan is needed → file the nerd line only.** No plan file, no plan mode. Keeps trivial
   items from cluttering `docs/plans/` and burning a planning round-trip for nothing.

5. **Result: bare `/inbox` is self-correcting.** It reaches for a plan exactly when one is warranted,
   whether or not the user remembered to start in plan-mode. `/inbox` and `/inbox`+plan converge on
   the *needed* items. Logging dates is [[timeline_provenance_stamps]]; reading them is
   [[history_crisscross]].

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

1. Edit `inbox` SKILL.md: in the classify step, for each item make a **needs-a-plan judgement** using
   the triggers in Decision 2 (state the verdict in the proposal so it's visible before any write).
2. For items that need a plan: **`EnterPlanMode`**, ask the clarifying questions, draft the plan,
   `ExitPlanMode` for approval, then write `docs/plans/<id>.md` + point the nerd line at it.
3. For items that don't: file the nerd line only — no plan file, no plan mode.
4. Add a `TEST.md` case: one needs-plan item (asserts plan mode + plan file) and one trivial item
   (asserts nerd-line-only, no plan file) — pins the gate so it can't silently drift.
5. Pairs with [[timeline_provenance_stamps]] (the date log) and [[history_crisscross]] (the reader).
