# Archive — June 2026

## 2026-06-30
- [ship_merge_helper] (skill) — /land: confirm-gated merge+push step (the one /fire, /ship, /forge refuse). ff-only merge of a branch into trunk (main|master), push trunk to origin, prune; refuses non-ff (rebase first), never force-pushes, pushes trunk only. Works in any repo (kit or app). self-test PASS (bare-origin sandbox: ff+push+prune + behind-branch refusal) → chore/forge_ship_merge_helper
- [inspect] (skill) — /inspect: read-only workforce auditor (kit | app); 3-layer SCAN→CONCLUDE→LEDGER engine, stable de-duped finding ids (insp_<check>_<slug>), append-only idempotent ledger so re-runs converge to silence; built ad-hoc (no inbox line), self-test PASS → chore/forge_inspect
- [inbox_plan_gate] (skill) — inbox plan gate: agent judges per item whether a plan is needed; if yes → EnterPlanMode + ask questions + write docs/plans/<id>.md + pointer nerd line, if no → nerd line only; TEST.md pins both paths; self-test PASS → chore/forge_inbox_plan_gate

## 2026-06-29
- [skill_builder] (skill) — /skill-builder: study top skills' structure, then scaffold a lean markdown-only skill (no python bloat); load-check-only self-test → chore/forge_skill_builder
- [polish_check] (skill) — /polish: `check` lists tsc+lint+format problems, `run` fixes the safe ones; never commits; self-test PASS → chore/forge_skill_builder

## 2026-06-28
- [skill_pipeline_tester] (skill) — /skill-tester: sandbox-drive any skill via its TEST.md, assert side effects + guardrails, teardown; wired as forge's self-test gate → chore/forge_skill_pipeline_tester
