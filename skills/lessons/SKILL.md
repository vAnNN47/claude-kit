---
name: lessons
description: After a hard bug is solved, distill the postmortem into the right permanent registry so recurrences are looked up, not re-researched. Routes by type — RN/Expo CODE bug → a new Known Issue in rn-debug's registry; tooling/plugin/env/build bug → bug-journal.md; portable rule → STANDARDS.md. Proposes the entry first, writes + commits (branch-always) only on confirm. Trigger on "/lessons", "lessons", "מסקנות", "write the lesson", "log this bug for the future", or right after a hard debugging win.
argument-hint: "[optional: one-line hint of which bug to distill]"
---

# lessons — distill a hard win into the registry

A nasty bug you just beat is worth an entry **once** — so the next hit is a lookup, not a
re-research. This skill turns the session's debugging into a registry entry and commits it.
Twin of the (planned) `/refinery`, which later re-checks an entry's `Search terms` upstream
before a workaround is re-applied.

All writes happen **in the claude-kit repo** (`~/.claude/skills/claude-kit/`, its own git
repo) — the registries travel to every clone.

## Steps

1. **Reconstruct from the session.** Pull the facts out of the conversation that just
   happened: symptom, environment/versions, wrong turns actually taken, proven root cause,
   the fix, how it was verified, search terms. **Only what was proven — never invent or
   pad.** A field the session doesn't support → ask the user or leave it out; a fabricated
   "wrong turn" poisons the registry.

2. **Heft gate.** Registries hold **mega-bugs only** — non-obvious, took real digging,
   would cost an hour+ to re-debug cold. A trivial fix (typo, missing import, doc-lookup
   answer) → say it doesn't clear the bar and stop. When in doubt, ask: "would future-you
   re-Google this for an hour?"

3. **Route by type** (one saga can produce entries in more than one registry — split it):

   | The lesson is a… | Target | Format |
   |---|---|---|
   | RN/Expo **code** bug (components, styling, keyboard, a11y, native modules) | `skills/rn-debug/SKILL.md` → **Known Issues** | next `KI-<n>`: Symptom / Root cause / Fix / ruled-out / **Versions seen on** / **Search terms** — and add it to the category index line |
   | **Tooling / plugin / env / build / editor** bug | `bug-journal.md` (repo root) | the file's entry template, **newest first** |
   | Portable **rule/preference** learned the hard way | `STANDARDS.md` | one bullet in the matching section |
   | App-specific quirk (one project's stack, not portable) | that app's `CLAUDE.md` — **not** claude-kit | app's own conventions |

4. **De-dupe before writing.** Grep the target registry for the same root cause / API /
   error string. Already there → **extend that entry** (bump `Versions seen on`, add a new
   wrinkle) instead of adding a near-duplicate.

5. **Propose, then write.** Show the drafted entry (full text, target file, KI number if
   applicable) and **wait for explicit confirm** — same write-gate as `/inbox`. No confirm →
   nothing written.

6. **Commit (branch-always).** STANDARDS: the trunk moves only by `/land` — bookkeeping
   included. Cut `chore/lesson_<slug>` off `main`, one conventional commit
   (`docs(bug-journal): …` / `docs(rn-debug): add KI-<n> …`), **no attribution footer,
   local only — never push.**

7. **Report.** The entry's registry + anchor (KI number / date heading), branch + commit,
   then name the next rung: `/land chore/lesson_<slug>` to publish.

## Rules

- **Session facts only.** Every claim in the entry must have happened: real error text,
  real ruled-out hypotheses, real version numbers (read `package.json`, don't guess).
- **Every entry carries `Search terms`** — that's the hook `/refinery` (planned) needs to
  re-check upstream before the workaround is re-applied.
- **Append/extend, never rewrite history.** Existing entries are the record; correcting one
  means extending it, not silently rewording it.
- **One lesson per branch/commit** — a saga that splits into two registries is still one
  branch, one commit (one concern: "record the lesson of <saga>").
- Write-gate is mandatory (step 5). Heft-gate is mandatory (step 2).

## Not this skill's job

- **Solving** the bug → `/rn-debug` (render mysteries) or plain debugging; lessons runs
  *after* the win.
- Re-checking whether upstream already fixed a catalogued issue → `/refinery` (planned).
- Publishing the commit → `/land`.
- Capturing raw ideas / future tasks → `/inbox`.
- App feature work → `/fire`.
