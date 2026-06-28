# Test: inbox
mode: run
trigger: /inbox add a dark mode toggle to settings
setup:
  copy: [CLAUDE.md, AGENTS.md]
  roadmap.md: empty-sections
confirm: yes                       # approve the proposed mapping unedited
expect:
  - roadmap.md gained one new entry under "Improvements"
  - that entry is a two-line block (plain line + "> nerd:" line)
  - the new id is lowercase snake_case and unique in roadmap.md
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
