---
name: inspect
description: Read-only auditor for the claude-kit workflow itself — and, with `app`, for the current app repo. Scans the skills/agents/STANDARDS (or the app's roadmap/plans/git), cross-checks each system rule against file & git reality, and appends dated findings to an append-only ledger with stable de-duped ids so repeat runs converge to silence instead of nagging. Never edits code; proposes findings and, on confirm, routes serious ones into roadmap.md so /fire drains them. Trigger on "/inspect", "inspect", "audit the workforce", "audit claude-kit", "check the skills", "scan for drift", or "/inspect app".
argument-hint: "[app|kit]"
---

# inspect — audit the workforce

Inspect the system, not the feature. Walk the site, find culprits (a skill referencing a moved
file, two skills claiming one trigger, a "done" commit carrying a forbidden footer), reason about
whether the crew can actually work, and log it. **Read-only: you never edit code.** You write the
ledger and, on confirm, propose roadmap items — nothing else.

> **Why this exists:** the fire/ship/inbox crew acts on the app but never checks *itself*. Rules in
> CLAUDE.md / STANDARDS.md drift from the skills that are told to obey them, and claims ("ran the
> gate", "no co-author footer", "branch not SHA") are never verified against git. This is the
> inspector the crew lacks — and it inspects the crew first.

## Scope (two targets, one engine)

- **`/inspect` (default) → kit.** Audit the claude-kit plugin itself: the skill `SKILL.md`s, their
  agents, `STANDARDS.md`, cross-skill consistency. "Is the workforce sound." Ledger → claude-kit
  repo `docs/audits/ledger.md`.
- **`/inspect app` → current app repo.** Audit this app's instance state: `roadmap.md`, `docs/plans/*`,
  Done/shipped lines, recent `git log`+`diff` vs the rules in its `CLAUDE.md`. Ledger → the app's
  `docs/audits/ledger.md`.

Each repo owns its own ledger and its own culprits. Same three layers below run either way; only the
check catalog differs.

## Steps

1. **Resolve target + locate.** `app` arg → app repo; else → the claude-kit plugin repo. Read that
   repo's rule sources first (kit: `STANDARDS.md` + every `skills/*/SKILL.md` frontmatter + agent
   defs; app: `CLAUDE.md → Workflow conventions`). The rules are the spec you audit *against* — never
   redefine them here.

2. **Layer 1 — SCAN.** Read, don't judge yet. Census the target: file tree, skill frontmatter,
   referenced paths, and (app) `git log --oneline -20` + relevant `git diff`. Collect raw facts.

3. **Layer 2 — CONCLUDE.** Cross-check each rule against reality. A finding = a *rule's claim* that
   the *files or git contradict*. Run the catalog for the target:

   **kit catalog:**
   - **dead path** — a skill references a file/path that has moved or is missing (`STANDARDS.md`,
     `docs/plans/`, a sibling skill).
   - **drift** — a skill inlines a rule it is told to read from single-source (e.g. inbox says
     "don't redefine the layout" → assert it does not embed the roadmap-format spec).
   - **contradiction** — two skills claim the same trigger, or one asserts X and another not-X.
   - **orphan** — a skill named in CLAUDE.md/STANDARDS but missing, or present but never referenced;
     a `Not this skill's job` footer pointing at a neighbour that doesn't exist.
   - **won't-load** — frontmatter that breaks: `name` ≠ folder, missing `description`, unquoted
     bracket hint.

   **app catalog (claims vs git):**
   - commit carries `Co-Authored-By` when CLAUDE.md forbids it.
   - Done line uses a 7-hex SHA where the rule says branch-only.
   - branch prefix ≠ category (`bug→fix/`, `improvement→feat/`, `tech debt→chore/`).
   - `nerd:` pointer `see docs/plans/<id>.md` → file missing; or a plan with no roadmap item.
   - `roadmap_style:` declared but layout doesn't match (flat vs section).
   - a "Done (unverified)" item whose tree currently fails `npm run check`/`lint`.
   - duplicate or reused id across `roadmap.md` + `archive/`.

4. **Layer 3 — REPORT + LEDGER (idempotent).** For each finding compute a **stable id**
   `insp_<check>_<location-slug>` — deterministic, greppable, never random. Then reconcile against
   the ledger so repeat runs converge:
   - id **not in ledger** → append a new `state:open` block, `found:` today.
   - id **already open, still dirty** → no-op (dedup — do *not* re-append).
   - id **open but condition now clean** → flip `state:fixed`, stamp `fixed:` today.
   - id **state:acked** (user marked false-positive) → skip silently, never re-raise.
   Ledger block format:
   ```
   - [insp_<check>_<slug>] sev:high  state:open  found:2026-06-30  fixed:—
     target:  kit
     claim:   STANDARDS.md single-sources roadmap layout
     reality: skills/inbox/SKILL.md:14-33 inlines the format spec
     suggest: replace inlined spec with a pointer  (roadmap item? y/n)
   ```

5. **Propose, then route on confirm.** Print the run summary: NEW / still-open / newly-fixed counts
   + each new finding one line. Write the ledger. For `sev:high` findings, *offer* to file a
   roadmap item (kit→`SKILLS-TODO.md`, app→`roadmap.md`) referencing the finding id — written only
   after the user confirms, same as `/inbox`. Fixes happen later via `/fire`/`/forge`, not here.

## Rules

- **Read-only, always.** No code edits. Only writes: the ledger, and confirmed roadmap items. This
  is what makes repeat runs safe — inspect cannot create the drift the next inspect finds.
- **Idempotent or it's a hell loop.** Stable id + dedup + `acked` state are mandatory. A healthy
  target converges to *zero new findings* and goes quiet; that silence is the acceptance test. If a
  re-run re-appends an unchanged finding, the dedup is broken — fix it, don't ship it.
- **Append-only ledger.** Never delete a finding; flip its `state`. History (found-date vs
  fixed-date) is the point.
- **One target per call.** `/inspect` then `/inspect app` = two runs, two ledgers.
- **Audit against the rules, never restate them.** STANDARDS/CLAUDE.md are the source of truth; you
  read them, you don't re-author them.

## Not this skill's job

- Routing a brain-dump into the queue → `/inbox`.
- *Fixing* a finding (branch, gate, commit) → `/fire` (app) / `/forge` (kit) drains the routed item.
- Archiving verified Done items → `/ship`.
- Authoring a new skill → `/skill-builder`; proving one behaves → `/skill-tester`.
