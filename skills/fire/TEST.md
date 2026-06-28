# Test: fire
mode: run
trigger: /fire darkmode_toggle
setup:
  copy: [CLAUDE.md, AGENTS.md]
  roadmap.md: |
    # Roadmap — sandbox

    ## 🐞 Bugs

    _(none)_

    ## ✨ Improvements

    - [darkmode_toggle] — Add a dark mode toggle to settings.
      > nerd: add a Switch in src/dummy.ts that flips a theme flag. Trivial.

    ## 🛠 Tech debt

    _(none)_

    ## ✅ Done (unverified)

    _(empty)_
  files:
    - src/dummy.ts
    - package.json: tsc+lint-pass-stub
confirm: yes
expect:
  - branch "feat/darkmode_toggle" exists
  - commits == 1
  - commit-subject contains "[darkmode_toggle]"
  - commit-body excludes "Co-Authored-By"
  - tsc and lint scripts were both invoked before the commit
  - roadmap.md "Done (unverified)" contains "[darkmode_toggle]"
  - that Done entry contains "(fired" with branch + commit metadata
  - roadmap.md "Improvements" no longer contains "[darkmode_toggle]"
guardrails:
  - no "git push" ran
  - no commit carries an attribution footer
