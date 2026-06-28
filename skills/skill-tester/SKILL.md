---
name: skill-tester
description: Smoke-test any skill end-to-end in a throwaway sandbox by reading its TEST.md spec and asserting the real side effects + global guardrails, then tearing the sandbox down. Drives the actual skill against a faked working directory — a true integration test, not a re-run of its logic. Trigger on "/skill-tester <name>", "test the skill", "smoke test the pipeline", or as forge's final gate on a freshly built skill.
argument-hint: "[skill-name] [--keep]"
---

# skill-tester — prove a skill actually works

Run a skill for real against a disposable sandbox, then check it did what its `TEST.md`
promised. The point is to catch a broken skill **at build time** (forge's gate) instead of
mid-task. Nothing here touches a real repo, real git history, or the real `roadmap.md`.

> **Why this exists:** `forge` load-checks that a new skill *loads* — but a skill can load
> fine and still mangle its side effects (wrong roadmap format, a stray `Co-Authored-By`,
> a `git push`). load-check is spelling; this is behavior.

The trick: a skill reads the *current app's* `CLAUDE.md` for its format rules and acts on the
*current working directory*. So if the sandbox holds a copied `CLAUDE.md` and we run the skill
from inside it, the **real skill** operates on **fake state** — only the target dir is faked.

## The TEST.md spec

Every skill should ship `skills/<name>/TEST.md` next to its `SKILL.md`. It declares what to
fire, what the sandbox needs, and what must be true afterward. Format:

```
# Test: <name>
mode: run                          # run (default) | load-check-only | smoke
trigger: /<name> <args>            # what to invoke inside the sandbox
setup:                             # fixtures to materialize before the run
  copy: [CLAUDE.md, AGENTS.md]     # copied from the real project (format rules)
  roadmap.md: empty-sections       # empty-sections | a literal seed block
  files:                           # extra fixtures the run needs
    - src/dummy.ts
    - package.json: tsc+lint-pass-stub   # so fire's verify gate runs green
confirm: yes                       # auto-supply any confirm gate the skill asks for
expect:                            # assertions — ALL must pass
  - roadmap.md contains "[<id>]"
  - branch "feat/<id>" exists
  - commits == 1
  - commit-body excludes "Co-Authored-By"
  - file "archive/2026/*.md" contains "(improvement)"
guardrails:                        # global, asserted for EVERY skill regardless of spec
  - no "git push" ran
  - no commit carries an attribution footer
```

`mode: load-check-only` → stop after the load-check (use for skills that mutate a real repo
the sandbox can't fake, e.g. `forge` commits into claude-kit itself). `mode: smoke` or **no
TEST.md** → generic smoke pass (see step 5), reported as `SMOKE-ONLY` — a soft warning, not a
hard fail. Forged skills are expected to ship a real `run` spec.

## Steps

1. **Resolve target(s).** The named skill, or — with no arg — the bundled pipeline trio
   `inbox`, `fire`, `ship` in order (a full end-to-end pipeline run). For each, locate
   `skills/<name>/{SKILL.md,TEST.md}`. No `SKILL.md` → list the closest names and stop.

2. **Load-check (always, read-only).** Re-read the skill's frontmatter: `name` equals its
   folder, `description` / `argument-hint` are strings, a bracketed `argument-hint` is quoted.
   Fail here = hard fail; skip the rest for this skill. `mode: load-check-only` stops here with
   a PASS.

3. **Setup sandbox.** Make `skilltest-<timestamp>/` under the session scratchpad, `git init`,
   then materialize the spec's `setup:` — copy the real `CLAUDE.md`/`AGENTS.md`, write
   `roadmap.md` (empty sections or the seed block), a `package.json` whose `tsc`/`lint` scripts
   are **pass stubs** (`exit 0`), and any `files:`. One initial commit so the tree is clean.
   **Save the real cwd**, then switch cwd into the sandbox.

4. **Drive the real skill.** Invoke it via the spec's `trigger:` from inside the sandbox,
   auto-supplying `confirm:` gates. Do **not** re-implement the skill — run the actual one; that
   is what's under test. (If a skill genuinely needs user input the spec didn't pre-answer,
   that's a spec bug — report it.)

5. **Assert.** Check every `expect:` line plus the global `guardrails:` (inspect the sandbox
   git log + working tree). With no spec, the smoke pass asserts only: the skill ran without
   error, produced some output, and broke no guardrail. Record each assertion PASS / FAIL.

6. **Report.** Per skill: a table of assertion → PASS/FAIL, any `SMOKE-ONLY` note, and an
   overall verdict. Be specific on failure — name the assertion and show the offending value
   (e.g. `commit-body excludes "Co-Authored-By" → FAIL: footer present`).

7. **Teardown.** Restore the original cwd and `rm -rf` the sandbox. Then confirm the real repo
   is untouched (real `roadmap.md` + `git log` unchanged). `--keep` skips teardown so you can
   inspect the sandbox after a failure.

## Rules

- **Sandbox only.** Never run the skill-under-test against a real repo. If a skill can't be
  faked in a sandbox, its spec must be `load-check-only` — don't improvise a live run.
- **Guardrails are non-negotiable.** A `git push` or an attribution footer fails the skill even
  if every `expect:` passed.
- **Read-only on the real tree.** The only real-filesystem writes are inside the scratchpad
  sandbox; everything else is read-only.
- A failing test is a **hard fail** that should block forge's commit/archive — surface *which*
  assertion broke, don't summarize it away.

## Not this skill's job

- Building or editing the skill it tests → `/forge`.
- Sorting ideas into the tooling queue → `/inbox`.
- The rigorous draft→eval→optimize loop for one skill's *output quality* → `skill-creator`
  (that judges prompt quality; this checks side effects + guardrails).
- App feature/bug work → `/fire`; archiving app work → `/ship`.
