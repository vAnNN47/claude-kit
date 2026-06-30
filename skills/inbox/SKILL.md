---
name: inbox
description: Capture a raw idea/brain-dump and route each item to the right place — app task → roadmap.md, tooling task → SKILLS-TODO.md, capability gap → flagged. Proposes a mapping first, writes only after the user confirms. Trigger when the user pastes ideas/notes to file, says "inbox this", "/inbox", "triage these", or dumps a list of things to do.
---

# inbox — capture & route

Turn a messy brain-dump into correctly-filed work. **You never write until the user
confirms the proposed mapping.**

First, read the current app's `CLAUDE.md → Workflow conventions` for the roadmap format,
category meanings, ID rules, and lifecycle. Those rules win; do not redefine them here.

## Roadmap layout (two tactics)

A roadmap uses one of **two layout tactics**, declared in `CLAUDE.md → Workflow conventions` as
`roadmap_style: section | flat`. The **`roadmap` skill** is the source of truth for both shapes,
plus `roadmap init` (pick a tactic for a new project) and `roadmap convert` (flip A↔B losslessly) —
inbox only *reads* the tactic and files into it:

- **`section`** — items grouped under category headers `🐞 Bugs` / `✨ Improvements` /
  `🛠 Tech debt` / `✅ Done (unverified)`. The header *is* the category; no inline tag.
  ```
  ## ✨ Improvements
  - [id_task_slug] — regular-dude one-liner.
    > nerd: technical approach / where + how.
  ```
- **`flat`** — one `## To do` list; category rides inline as `_(bug)_` / `_(improvement)_` / `_(tech debt)_`:
  ```
  ## To do
  - [id_task_slug] regular-dude one-liner. _(improvement)_
    > nerd: technical approach / where + how.
  ```

**Resolving the active tactic:**
- If `roadmap_style:` is set in `CLAUDE.md`, obey it silently.
- If it's **missing** (new/unconfigured project), run `roadmap init` to let the user pick a tactic
  and persist it, *before* filing anything.
- After the tactic is known, still **ask the user how to section the batch** — confirm each item's
  category (bug / improvement / tech debt), since that drives the header (`section`) or the inline
  `_(bug)_` / `_(improvement)_` / `_(tech debt)_` tag (`flat`).

## Plan gate (app tasks)

Not every item needs a plan — but the ones that do must get one, whether or not the user remembered
to start in plan mode. So **judge each app task**: does it need a committed `docs/plans/<id>.md`?

- **Needs a plan** (any one): a build-approach decision (e.g. vanilla vs framework island, schema
  shape, new collection), multi-step work, real ambiguity / needs investigation, or a large
  brain-dump.
- **No plan**: a clear one-liner with an obvious approach (e.g. "make the header text red").

If **any** item needs a plan and you are **not already in plan mode**, call `EnterPlanMode` before
proposing, **ask the clarifying questions** that plan needs, and draft the plan(s) there. On approval
(`ExitPlanMode`) write each `docs/plans/<id>.md` and point that item's `> nerd:` line at it
(`> nerd: … — see docs/plans/<id>.md`). Items that don't need a plan keep the normal inline nerd line.
The plan-file spec (frontmatter, "nerd line → pointer") lives in the app `CLAUDE.md → Workflow
conventions` / claude-kit `STANDARDS.md` — obey it, don't redefine it here.

## Steps

1. **Split.** Break the user's input into discrete items (one idea = one item). A single
   pasted blob often holds several.

2. **Classify** each item into exactly one bucket:
   - **App task** → belongs in this app's `roadmap.md`. Pick the category:
     - *bug* = broken / wrong behavior
     - *improvement* = new or better feature / UX
     - *tech debt* = internal quality, no user-facing change
     Then draft the entry in the **active tactic** (see *Roadmap layout* above): a stable
     `[id_task_slug]` (lowercase snake `area_thing_problem`, unique — grep roadmap.md +
     archive/ to avoid collisions), a regular-dude one-liner (with a `_(<cat>)_`
     tag appended if the tactic is `flat`), and a `> nerd:` technical line.
   - **Skill / tooling task** (work on the workflow or other skills) → `SKILLS-TODO.md`
     in the claude-kit plugin repo (later drained by `/forge`, the tooling twin of `/fire`).
   - **Capability gap** = a recurring need with no tool yet. Do NOT build anything.
     Flag it and recommend one of: new *skill* (note: search the user's skill registry
     first, else `skills-creator`), new *instruction* (a CLAUDE.md rule), or just a
     *component* (reusable code — most "make X reusable" items are this, not a skill).
   - **Portable rule / preference** ("from now on, everywhere…") → a committed file, **never
     machine-local memory** (STANDARDS → "A portable rule you learn mid-task goes into claude-kit"):
     cross-app rule → `STANDARDS.md`; cross-app bug recipe → `bug-journal.md`; skill behavior →
     the relevant `skills/*/SKILL.md`; app-specific → that app's `CLAUDE.md`. `~/.claude/.../memory/`
     doesn't clone — a durable rule parked there dies on one machine.

3. **Plan gate.** For each app task, apply the **Plan gate** (above): mark it *needs-plan* or
   *no-plan*. If any item needs a plan and you're not already in plan mode, `EnterPlanMode` now and
   ask the clarifying questions before proposing.

4. **Ask when unsure.** If an item is ambiguous (category unclear, or app-vs-tooling
   unclear), ask the user one focused question instead of guessing.

5. **Propose.** Show the full mapping as a table/list: each item → bucket → category →
   id → *plan verdict* → the exact lines that would be written (in the active tactic's shape).
   For needs-plan items, include the drafted plan (you are in plan mode). Group capability gaps with
   your recommendation. Do not touch any file yet.

6. **Confirm → write.** After the user approves (and applies any edits), append entries:
   - app tasks → correct section of `roadmap.md` (new items go to the *bottom* of their
     section unless the user says it's high priority — order = priority)
   - needs-plan items → also write `docs/plans/<id>.md` and make the nerd line a pointer to it
   - tooling tasks → `SKILLS-TODO.md`
   - capability gaps → the flagged list in `SKILLS-TODO.md`
   Then summarize what was written and where.

## Rules

- Never auto-create skills or components from inbox — capability gaps are *flagged only*.
- Keep IDs greppable and never reuse a retired id.
- One idea can only land in one bucket. If it's genuinely two things, split it.
- **Don't redefine the layout.** Read the tactic; `roadmap convert` owns A↔B switches, not inbox.
- **Plan gate, both ways.** File a plan only for items that need one (never blanket-plan a trivial
  one-liner), and never skip a plan an item does need. The judgement is the gate — see *Plan gate*.
