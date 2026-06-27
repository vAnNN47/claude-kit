---
name: ship
description: Sweep verified items from roadmap.md's "Done (unverified)" section into archive/[year]/[mm-month].md, after the user confirms which are actually tested. Bookkeeping only — moves entries, never merges or pushes. Trigger on "/ship", "ship", "archive done", or "clear the done list".
---

# ship — confirm & archive

Promote tested work from `✅ Done (unverified)` to the permanent archive.

Read the current app's `CLAUDE.md → Workflow conventions` first for the archive path and
entry format.

## Steps

1. **List.** Read the `✅ Done (unverified)` section of `roadmap.md` and show every item
   with its metadata (date · branch · commit).

2. **Confirm.** Ask the user which items are verified — **all**, or a selected subset.
   Some may still be untested (batched work); only move what the user confirms. If none
   are confirmed, stop and change nothing.

3. **Archive.** For each confirmed item, append to `archive/[year]/[mm-month].md`
   (e.g. `archive/2026/06-june.md`; create the file/dirs if missing). Keep the category
   tag and metadata:
   ```
   ## YYYY-MM-DD
   - [id] (bug) — plain desc. → branch · commit
   ```
   Group under the date heading; create the heading if today's isn't there yet.

4. **Remove** the archived items from `roadmap.md`'s `Done (unverified)` section.
   **Move, never delete** — the entry now lives in the archive.

5. **Report** what was archived and what (if anything) stayed in Done (unverified).

## Rules

- Bookkeeping only — **no merge, no push, no branch deletion.** Remote git is the user's job.
- Never archive an unconfirmed item.
- Preserve history: archive is append-only; never rewrite past month files.
