# Test: inbox
mode: run
trigger: |
  /inbox 1. build a portfolio image gallery with tag filtering and a lightbox
  2. make the homepage header text red
setup:
  copy: [CLAUDE.md, AGENTS.md]
  roadmap.md: empty-sections
confirm: yes                       # approve the proposed mapping unedited
expect:
  # both items land in the roadmap
  - roadmap.md gained two new entries, each a two-line block (plain line + "> nerd:" line)
  - each new id is lowercase snake_case and unique in roadmap.md
  # plan gate — the complex item gets a plan, the trivial one does not
  - a "docs/plans/*.md" file exists for the gallery item (build-approach decision => needs a plan)
  - the gallery item's "> nerd:" line points at its docs/plans/<id>.md file
  - NO plan file was created for the "header text red" item (clear one-liner => no plan)
  - the "header text red" item's "> nerd:" line is an inline approach, not a pointer
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
