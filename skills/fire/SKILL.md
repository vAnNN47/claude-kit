---
name: fire
description: Execute one roadmap item end-to-end by its id — branch, implement, run tsc+lint, commit, then move the item to "Done (unverified)". One id, one branch, one commit, local only (never pushes). Trigger on "/fire <id>", "fire <id>", "do <id>", or "implement <id>" where the id matches a roadmap.md entry.
---

# fire — execute one roadmap item

Take a single `[id]` from `roadmap.md` to a committed, locally-isolated change.

Read the current app's `CLAUDE.md → Workflow conventions` first for branch prefixes,
commit rules, and the lifecycle. Those rules win.

## Steps

1. **Locate.** Find `[id]` in `roadmap.md`. If not found, list the closest matches and
   stop — do not guess which item the user meant.

2. **Understand.** Read the item's `> nerd:` line and the relevant code it points at.

3. **Branch.** From the item's category, create a branch off the default branch:
   - bug → `fix/<id>` · improvement → `feat/<id>` · tech debt → `chore/<id>`
   Never work directly on the default branch.

4. **Implement** the change described by the nerd line.

5. **Verify before committing.** Run the project's checks — TypeScript (`npx tsc
   --noEmit`) and lint (e.g. `npm run lint`), plus tests if the project has them. If any
   fail, fix them. **Do not commit broken code.** If you truly cannot make it pass,
   report the failure and stop (leave work on the branch).

6. **Commit.** One conventional commit; subject derived from the id + plain line
   (`fix: drawer button hit target [drawer_button_acc]`). Include the
   `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` footer.

7. **Update roadmap.** Move the item from its section to `✅ Done (unverified)` with
   metadata: `(fired YYYY-MM-DD · branch <branch> · commit <shortsha>)`.

8. **Report.** Summarize what changed, the branch + commit, and remind the user to test
   it then run `/ship`.

## Rules

- **Exactly one id per call.** Batching = run fire again. Keeps branches/commits isolated
  and revertible.
- **Local only.** Never `git push`, open a PR, or merge. The user handles remote git.
- Verify gate is mandatory — committing red is the failure mode this skill exists to prevent.
