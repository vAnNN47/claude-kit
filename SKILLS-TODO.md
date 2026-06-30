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
- [skill_lessons] — /lessons (מסקנות): after a hard bug is solved, distill the recipe so recurrences
  are looked up, not re-researched. Route by type: an RN/Expo **code** bug → a new `rn-debug` Known
  Issue (symptom / root-cause / fix / versions / search-terms); a **tooling/plugin/env** bug →
  `bug-journal.md` (both registries now exist + seeded). Commit per existing rules. Twin of the first
  app's /logbug. Pairs with [skill_refinery] (which reads a KI's `versions`+`search-terms` to re-check
  upstream before re-applying the fix).
- [inbox_plan_gate] — make heft, not the command, decide the plan file. inbox judges each item:
  trivial one-liner → nerd line only; complex (multi-step / build-approach decision / needs
  investigation) → `docs/plans/<id>.md` always, nerd line → pointer. Recommend + create by default,
  explicit opt-out. Rejected auto-entering plan-mode (wrong tool; plan-mode = deciding, not logging).
  Plain `/inbox` and plan-mode + `/inbox` then converge. See docs/plans/inbox_plan_gate.md.
- [timeline_provenance_stamps] — every roadmap/archive item carries dated frontmatter
  (`inboxed:` / `fired:` / `shipped:`). /inbox stamps `inboxed`, /fire stamps `fired`, /ship stamps
  `shipped`. This is a cheap *log* on EVERY item (text changes included), distinct from the
  heft-gated *plan doc* (`docs/plans/<id>.md`, complex items only). Purpose: trace an item across the
  inbox→ship gap (e.g. inboxed Jun 30, shipped Aug 12). Add the rule to each app's CLAUDE.md workflow
  block + teach inbox/fire/ship to write the stamps. Powers [history_crisscross].
  See docs/plans/timeline_provenance_stamps.md.
- [history_crisscross] — /history <topic>: read-only query crossing `docs/plans/` ↔
  `archive/[year]/[mm-month].md` ↔ `git log`, answering "when did we decide / change / ship X?".
  Consumes the [timeline_provenance_stamps] dates. May rent a read-only investigator subagent for big
  greps. It is a **skill** (on-demand query), not a standing agent. Sibling of [where_was_i]
  (cold-start "where am I now") — this is temporal lookup of *past* decisions; keep distinct, share
  the date-reading helper. See docs/plans/history_crisscross.md.

## Capability gaps (flagged by inbox, not yet actioned)

- [version_delta_tracking] — diff "shipped to prod" vs "in main, not yet released"
  (`git log release..main`, or an `[Unreleased]` CHANGELOG section). **NOT needed yet:** apps
  auto-deploy `main` via Cloudflare Pages — no release branch/tag, so there is no prod-vs-next delta
  to compute. Build the day a **staged release** exists (main = next, a `release` branch/tag = live),
  not before. Parked = YAGNI until staged deploys. See docs/plans/version_delta_tracking.md.
