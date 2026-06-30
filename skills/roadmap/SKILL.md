---
name: roadmap
description: Owns the roadmap.md layout spec and the two supported layout tactics — `section` (category-first headers, RN house style) and `flat` (lifecycle-first headers + inline `_(bug)_`/`_(improvement)_`/`_(tech debt)_` tag, the Leetbeck style). `roadmap init` picks a tactic for a new project and writes the Workflow-conventions block into CLAUDE.md; `roadmap convert` flips an existing roadmap.md + CLAUDE.md between the two tactics, losslessly. inbox/fire/ship read the chosen tactic from CLAUDE.md's `roadmap_style:` line — they never redefine it. Trigger on "/roadmap init", "/roadmap convert", "roadmap init", "convert roadmap style", "switch roadmap layout", "pick roadmap tactic".
---

# roadmap — pick & convert the roadmap layout tactic

There are **two supported layout tactics** for `roadmap.md`. Both carry the same facts; they differ
only in the **sort axis** and where the category lives. A project picks **one** and records it in
`CLAUDE.md → Workflow conventions` as a single line:

```
roadmap_style: section   ← Tactic A
roadmap_style: flat      ← Tactic B
```

`inbox`, `fire`, and `ship` read that line and act accordingly. They never invent the format — this
skill is the single source of truth for both shapes.

## The two tactics

Shared by both (invariants — never drop these on convert):
- Stable `[id]` — lowercase snake `area_thing_problem`, short, unique, greppable, **never reused**.
- Two-audience entry: a **regular-dude** one-liner + a `> nerd:` technical line.
- Three categories: *bug* (broken/wrong behavior) · *improvement* (new/better feature or UX) ·
  *tech debt* (internal quality, no user-facing change).
- Lifecycle: open work → `✅ Done (unverified)` → `archive/`. Move, never delete.
- **Order within a section = priority** (top = first). No priority field.

### Tactic A — `section` (category-first)

Headers are the categories. Which section an item sits under **is** its category.

```markdown
# Roadmap — <App>

Format + rules: see CLAUDE.md → "Workflow conventions". Order in each section = priority.

## 🐞 Bugs
## ✨ Improvements

- [goals_progress_slider] — Drag a slider to set goal progress instead of tapping presets.
  > nerd: replace the PROGRESS_STEPS Chip row in goal/[id].tsx with a slider. Keep 0–100 clamp.

## 🛠 Tech debt
## ✅ Done (unverified)
```

### Tactic B — `flat` (lifecycle-first + inline tag)

Headers are lifecycle stages. Category rides **inline** on the regular-dude line as one of
`_(bug)_` / `_(improvement)_` / `_(tech debt)_`. Optional `## Later / parked` for someday/maybe.

```markdown
# Roadmap — <App>

Format + rules: see CLAUDE.md → "Workflow conventions". Order in each section = priority.

## To do

- [goals_progress_slider] Drag a slider to set goal progress instead of tapping presets. _(improvement)_
  > nerd: replace the PROGRESS_STEPS Chip row in goal/[id].tsx with a slider. Keep 0–100 clamp.

## ✅ Done (unverified)

## Later / parked
```

Per-entry shape, flat: `- [id] <regular-dude line>. _(<category>)_` then the `> nerd:` line.
(`✅ Done (unverified)` items in both tactics carry the `(fired YYYY-MM-DD · branch …)` breadcrumb that
`/fire` adds — branch only, never a SHA.)

## Verbs

Parse the arg: `convert` → convert mode; `init`, empty, or anything else → init mode. State the
resolved verb in the first output line.

### `roadmap init` — new project, pick a tactic

1. If `CLAUDE.md` already has a `roadmap_style:` line, report it and stop (use `convert` to change).
2. Otherwise **ask the user which tactic** (AskUserQuestion: `section` vs `flat`), with a one-line
   pitch each:
   - **section** — scan by kind; best when bugs vs features vs debt is the axis you triage on.
   - **flat** — scan by what's next; one queue, category as a tag; best for a small solo backlog.
3. Write the `roadmap_style: <choice>` line + the matching format block into
   `CLAUDE.md → Workflow conventions` (create the section if absent), and scaffold an empty
   `roadmap.md` in the chosen shape if one doesn't exist.

### `roadmap convert` — flip an existing roadmap A↔B

1. **Detect** current tactic: read the `roadmap_style:` line; if missing, infer from headers
   (`🐞 Bugs`/`✨ Improvements`/… ⇒ `section`; `To do` ⇒ `flat`) and confirm with the user.
2. **Re-shape every item**, preserving id, both lines, breadcrumbs, and intra-category order:
   - **section → flat:** collapse the category sections into `## To do`, appending each item's
     category as `_(<category>)_` on its regular-dude line. Keep `✅ Done (unverified)`
     as-is. Map any items the user calls someday/maybe into `## Later / parked` (ask if unsure).
   - **flat → section:** read each item's `_(<category>)_` tag, drop the tag, and file the item under
     the matching `## 🐞/✨/🛠` header. An item with **no** tag → ask the user its category; never guess.
3. **Update the `roadmap_style:` line** and swap the embedded format block in CLAUDE.md to match.
4. **Show a diff and confirm before writing.** Conversion is lossless — every id in must equal every
   id out. If a count mismatches, stop and report.

## Rules

- **One source of truth.** The format block + `roadmap_style:` line live in the app's CLAUDE.md;
  this skill writes them. inbox/fire/ship only *read* the tactic.
- **Lossless convert.** Same ids, same order, same nerd lines — only the sort axis + category
  placement change. Verify id-count in == out.
- **Never guess a category.** flat→section with an untagged item ⇒ ask.
- **Never git.** No add/commit/push — staging is the user's.
- **Invariants are non-negotiable** across both tactics (stable ids, two-audience entries, lifecycle).
