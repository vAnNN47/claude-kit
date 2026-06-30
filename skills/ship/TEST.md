# Test: ship
mode: run
trigger: /ship
setup:
  copy: [CLAUDE.md, AGENTS.md]
  roadmap.md: |
    # Roadmap — sandbox

    ## 🐞 Bugs

    _(none)_

    ## ✨ Improvements

    _(none)_

    ## 🛠 Tech debt

    _(none)_

    ## ✅ Done (unverified)

    - [darkmode_toggle] — Add a dark mode toggle to settings.
      (fired 2026-06-28 · branch feat/darkmode_toggle)
confirm: yes                       # confirm darkmode_toggle is verified
expect:
  - file "archive/2026/*.md" exists
  - that archive file contains "[darkmode_toggle]"
  - that archive file line carries the "(improvement)" category tag
  - that archive file line keeps the branch metadata
  - roadmap.md "Done (unverified)" no longer contains "[darkmode_toggle]"
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
