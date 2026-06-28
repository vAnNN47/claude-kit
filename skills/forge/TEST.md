# Test: forge
mode: load-check-only   # forge commits into the claude-kit repo itself; a sandbox can't fake that
trigger: /forge some_slug
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
