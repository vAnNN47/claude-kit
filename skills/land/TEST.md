# Test: land
mode: run
trigger: /land feat/x
setup:
  # Richer git fixture than the standard grammar — the runner materializes it by hand:
  git-remote: bare                 # a bare repo cloned as "origin"; master pushed to it once
  branches:
    master: one seed commit, also present on origin/master
    feat/x: master + 2 commits (ahead, fast-forwardable, NOT pushed to origin)
  files:
    - dummy.txt                    # touched on feat/x so it has real commits to land
confirm: yes                       # approve the step-3 land plan unedited
expect:
  - master fast-forwarded to feat/x tip (git rev-list master..feat/x == 0 after)
  - origin received the push (bare origin master == local master HEAD)
  - feat/x branch pruned (git branch excludes feat/x)
  - merge was fast-forward — zero merge commits created (git rev-list --merges base..master == 0)
  - second scenario: a feat/y that is BEHIND master is REFUSED (no merge, no push, tree unchanged)
guardrails:
  - no force-push ran (no "--force" / "+refs" in the push)
  - only the trunk ref reached origin — no feat/* branch on origin
  - working tree clean at end; trunk branch never deleted
