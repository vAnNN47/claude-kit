# Skills TODO — claude-kit

Tooling backlog (the `inbox` skill routes *skill tasks* and *capability gaps* here).
App tasks go to each app's `roadmap.md` instead.

## Ideas / gaps

- [ship_merge_helper] — Optional companion to /ship that opens a PR or merges verified
  branches (kept OUT of ship by design; ship is local bookkeeping only). Decide later.
- [explain_target] — /explain <file|function|skill>: read it, output what / why /
  callers / gotchas for fast re-orientation after time away.
- [where_was_i] — advisor for cold-start: read roadmap.md + git log + last branch +
  Done(unverified), output "you were doing X, next Y, N in queue". No /wtf needed.
- [skill_refinery] — /refinery: before solving a known recurring RN problem with custom code, scan
  installed packages (machine-scope skills dir) + web-search whether a newer upstream version already
  fixes it; try upstream first, verify with the user, else fall back to the local package.
- [skill_lessons] — /lessons (מסקנות): after a hard bug is solved, distill the recipe into a new
  rn-debug Known Issue (symptom / root-cause / fix / versions) + commit & push per existing rules, so
  recurrences are looked up, not re-researched. Twin of the first app's /logbug.
- [polish_check] — /polish: local quality gate that runs the project's type-check + lint +
  format check, parses the output, and reports errors/warnings grouped by file (no branch, no
  commit). Lightweight read-only twin of /fire's gate. Per-stack commands: Astro/TS → `astro check`
  (tsc) + `eslint` (eslint-plugin-astro) + `prettier --check`; detect from package.json scripts/deps.
  NOTE: Astro-Leetbeck site has no eslint/prettier wired yet — skill should detect-and-offer-to-add,
  or fall back to `astro check` only. Optional `--fix` to apply eslint/prettier autofixes.

## Capability gaps (flagged by inbox, not yet actioned)

_(empty)_
