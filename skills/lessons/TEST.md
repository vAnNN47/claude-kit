# TEST — lessons

mode: load-check-only

Reason: the skill's side effects are appends + a branch/commit **in the real claude-kit
repo itself** (bug-journal.md, skills/rn-debug/SKILL.md, STANDARDS.md) driven by facts
reconstructed from a live debugging conversation — there is no meaningful faked-workdir
sandbox: the input is session history, and the mutated repo is this one.

What a future sandboxed harness would assert (kept for reference):

expect:
- a proposed entry is shown and NOTHING is written before an explicit user confirm
- trivial-bug input is refused at the heft gate (no entry, no commit)
- RN/Expo code bug lands as `KI-<n>` in skills/rn-debug/SKILL.md Known Issues,
  n = max existing + 1, and the category index line gains the new KI
- tooling/env bug lands newest-first in bug-journal.md matching its template
- entry contains a `Search terms` line
- commit is on a fresh `chore/lesson_<slug>` branch, never on main

guardrails:
- no `git push`
- no `Co-Authored-By` / attribution footer in the commit
- no fabricated fields (every claim traceable to the driving transcript)
