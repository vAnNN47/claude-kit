# inspect ledger — target: kit

- [insp_stale_status_inbox_plan_gate] sev:med  state:fixed  found:2026-06-30  fixed:2026-06-30
  target:  kit
  claim:   docs/plans/<id>.md status reflects build state (a shipped plan is not "queued")
  reality: docs/plans/inbox_plan_gate.md:4 status:queued, but work is shipped — archive/2026/06-june.md:4 + commit 332dfaa + inbox SKILL.md Plan gate (L43-58). Fresh-context agent may rebuild.
  cause:   /forge step 8 archives the SKILLS-TODO line but never flips the plan file's status. Class fix = [timeline_provenance_stamps] (stamp shipped:).
  suggest: flip inbox_plan_gate.md to status:shipped; have /forge update plan status on archive  (roadmap item? y/n)
  fix:     flipped inbox_plan_gate.md -> status:shipped + shipped:2026-06-30 (chore/forge_inspect). Systemic /forge fix still owned by [timeline_provenance_stamps].
