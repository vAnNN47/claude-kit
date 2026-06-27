---
name: inbox
description: Capture a raw idea/brain-dump and route each item to the right place — app task → roadmap.md, tooling task → SKILLS-TODO.md, capability gap → flagged. Proposes a mapping first, writes only after the user confirms. Trigger when the user pastes ideas/notes to file, says "inbox this", "/inbox", "triage these", or dumps a list of things to do.
---

# inbox — capture & route

Turn a messy brain-dump into correctly-filed work. **You never write until the user
confirms the proposed mapping.**

First, read the current app's `CLAUDE.md → Workflow conventions` for the roadmap format,
category meanings, ID rules, and lifecycle. Those rules win; do not redefine them here.

## Steps

1. **Split.** Break the user's input into discrete items (one idea = one item). A single
   pasted blob often holds several.

2. **Classify** each item into exactly one bucket:
   - **App task** → belongs in this app's `roadmap.md`. Pick the category:
     - *bug* = broken / wrong behavior
     - *improvement* = new or better feature / UX
     - *tech debt* = internal quality, no user-facing change
     Then draft the entry: a stable `[id]` (lowercase snake `area_thing_problem`,
     unique — grep roadmap.md + archive/ to avoid collisions), a plain one-liner, and a
     `> nerd:` technical line.
   - **Skill / tooling task** (work on the workflow or other skills) → `SKILLS-TODO.md`
     in the claude-kit plugin repo.
   - **Capability gap** = a recurring need with no tool yet. Do NOT build anything.
     Flag it and recommend one of: new *skill* (note: search the user's skill registry
     first, else `skills-creator`), new *instruction* (a CLAUDE.md rule), or just a
     *component* (reusable code — most "make X reusable" items are this, not a skill).

3. **Ask when unsure.** If an item is ambiguous (category unclear, or app-vs-tooling
   unclear), ask the user one focused question instead of guessing.

4. **Propose.** Show the full mapping as a table/list: each item → bucket → category →
   id → the exact lines that would be written. Group capability gaps with your
   recommendation. Do not touch any file yet.

5. **Confirm → write.** After the user approves (and applies any edits), append entries:
   - app tasks → correct section of `roadmap.md` (new items go to the *bottom* of their
     section unless the user says it's high priority — order = priority)
   - tooling tasks → `SKILLS-TODO.md`
   - capability gaps → the flagged list in `SKILLS-TODO.md`
   Then summarize what was written and where.

## Rules

- Never auto-create skills or components from inbox — capability gaps are *flagged only*.
- Keep IDs greppable and never reuse a retired id.
- One idea can only land in one bucket. If it's genuinely two things, split it.
