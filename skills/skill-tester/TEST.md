# Test: skill-tester
mode: load-check-only   # the tester can't sandbox a run of itself; load-check is the gate
trigger: /skill-tester inbox
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
