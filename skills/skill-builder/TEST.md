# Test: skill-builder
mode: load-check-only   # fetches live skills.sh + authors by judgment — no deterministic sandbox run
trigger: /skill-builder demo-skill
why-load-check-only: >
  Step 2 fetches the live top-skills list from skills.sh (network, non-deterministic) and the
  output is an authored SKILL.md whose quality is a judgment call, not a checkable side effect.
  A sandbox run would either hit the network or fake it into meaninglessness. The frontmatter
  load-check is the honest gate here.
expect:
  - frontmatter name == "skill-builder"
  - SKILL.md has a "## Not this skill's job" footer
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
