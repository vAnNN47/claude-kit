# Test: inspect
mode: run
trigger: /inspect            # default target = kit (the sandbox below stands in as a kit repo)
setup:
  # a minimal kit-like tree with ONE planted culprit (a dead-path reference)
  STANDARDS.md: present
  skills/alpha/SKILL.md: |
    references docs/plans/MISSING.md   # <- planted dead path: file does not exist
  skills/beta/SKILL.md: clean          # no culprit
  docs/audits/ledger.md: absent        # first run must create it
confirm: no                            # do NOT file a roadmap item; ledger-only this run
expect:
  # Layer 3 wrote the ledger
  - "docs/audits/ledger.md now exists"
  - "exactly one finding block, state:open, for the alpha dead-path culprit"
  - "the finding id matches insp_<check>_<slug> (deterministic, greppable — not random)"
  - "the clean skill beta produced NO finding"
  - run-again: /inspect          # the mega-test: re-run in the same state
  - "second run appends ZERO new finding blocks (dedup by stable id)"
  - "second run reports the alpha finding as still-open, not as new"
guardrails:
  - no SKILL.md / STANDARDS.md / code file was edited (read-only)
  - no "git push" ran
  - ledger is append-only — the first run's block was not deleted or rewritten on the second run
