---
name: polish
description: Local quality pass with two modes. `polish check` (default) surveys type-check + lint + format and lists problems grouped by file — read-only, no writes. `polish run` fixes everything safely fixable (eslint --fix, prettier --write, mechanical deprecation / unused-symbol cleanups), re-checks, and reports what's left. Detects tools from package.json; never commits or pushes. Trigger on "/polish", "polish check", "polish run", "clean up the code", "fix lint", or a pre-commit sweep.
argument-hint: "[check|run]"
---

# polish — check it, then run the fixes

Two verbs over one toolchain:

- **`polish check`** (default) — survey the project's checks and **list** the problems. Read-only.
- **`polish run`** — actually **fix** the safely-fixable ones, re-check, report the rest.

> **Why this exists:** `/fire` runs tsc+lint as a commit gate; `/code-review` hunts logic bugs.
> Neither just *tidies*. polish does — `check` to see the state, `run` to clean it. The split keeps
> "show me" and "change my files" as separate, deliberate calls.

> **Standards:** the quality bar polish enforces is claude-kit `STANDARDS.md` (no-`any`, no unused
> imports/dead code, one-line JSDoc on exports, type-check + lint clean). Detect the project's stack
> and apply only the matching sections.

## Mode resolution

Parse the arg: `run` → fix mode; `check`, empty, or anything else → check mode. List the resolved
mode in the first line of output so it's never ambiguous.

## Steps

1. **Detect the toolchain.** Read `package.json` (+ `astro.config.*` / `tsconfig.json` / eslint +
   prettier config). Resolve three stages, preferring an existing npm script over a raw binary:
   - **type-check** → `npm run check` / `astro check` / `tsc --noEmit`
   - **lint** → `npm run lint` / `eslint .`
   - **format** → `npm run format:check` / `prettier --check .`
   Report what's wired and what's **missing** — never install; offer to wire a gap as a task.

2. **Survey (both modes).** Run each present stage, capturing findings: type errors, lint, format
   diffs, and any deprecation / unused-symbol hints. A stage with no tool is skipped (`— not
   configured`), not failed.

3. **`check` → report and stop.** Lead with the verdict (`clean` / `N errors, M warnings`) and a
   per-tool tally, then per-file findings worst-first (`line:col · rule/code · message`, errors
   above warnings). **No writes.** End by noting `run polish run to fix the safe ones`.

4. **`run` → fix, then re-check.** Apply, in order:
   - `eslint --fix`, then `prettier --write` — tool-driven, deterministic.
   - **Mechanical** code/config cleanups for clear findings: a deprecated compiler/config option, an
     unused import/interface, a dead flag. Only edits that **cannot change runtime behavior**; a fix
     with a tradeoff gets the minimal correct edit + a note.
   - **Never** touch judgement calls — real type errors, logic, API choices — leave them for the report.
   Then **re-run every stage**; the verdict comes from this post-fix pass. Report two lists:
   **Fixed** (with `git diff --stat`) and **Needs you** (per file, untouched).

## Rules

- **`check` writes nothing.** `run` only applies safe + mechanical fixes; uncertain = leave + report.
- **Re-verify.** `run`'s verdict is the post-fix re-run, never the first survey.
- **Never git.** No `git add`, commit, or push in either mode — staging is the user's.
- **Never install.** Missing eslint/prettier = a reported gap + an offer, not an `npm i`.
- **Prefer the project's own scripts** — they encode the user's config.
- **One project per call** — the current working directory.

## Not this skill's job

- Branch + commit + archive a roadmap item (with its tsc+lint gate) → `/fire`.
- Hunt logic/correctness bugs or review a diff → `/code-review`.
- Author a new skill → `/skill-builder`; commit a skill → `/forge`.
