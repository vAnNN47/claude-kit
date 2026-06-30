---
id: history_crisscross
created: 2026-06-30
status: queued
---

# Plan — /history: cross-reference past decisions by date (`history_crisscross`)

## Goal

Answer "when did we decide / change / ship X?" by crossing the durable records, on demand. Read-only
lookup of *past* work — not a cold-start "where am I now" (that is the existing [[where_was_i]]).

## Decisions (this is what was settled)

1. **Skill, not agent.** It is an on-demand, read-only query triggered when the user asks —
   `/history <topic>`. That is a slash command, not a standing background worker. Rule of thumb:
   **skill = the trigger + procedure; agent = optional muscle the skill rents.** It *may* spawn a
   read-only investigator subagent when the grep is large, but the user-facing thing is a skill.

2. **Sources it crosses:**
   - `docs/plans/<id>.md` — the design rationale + `created:` date.
   - `archive/[year]/[mm-month].md` — shipped history.
   - `git log` — commit-level when/what.
   - the [[timeline_provenance_stamps]] dates (`inboxed`/`fired`/`shipped`) — the spine that ties an
     id's design doc to its shipped archive entry across the time gap.

3. **Distinct from [[where_was_i]].** `where_was_i` = forward-looking cold-start ("you were doing X,
   next Y"). `history` = backward-looking temporal lookup ("when did X happen, when was it decided").
   Keep separate; share the date-reading helper.

## Steps

1. Author `skills/history/SKILL.md`: trigger `/history <topic>`, read the four sources, output a dated
   timeline for the topic (decided → inboxed → fired → shipped, with file/commit anchors).
2. Depends on [[timeline_provenance_stamps]] existing (otherwise only git log dates are available).
3. Decide subagent threshold: inline grep for small repos, rent `cavecrew-investigator` (or vanilla
   read-only) when sources are large.
