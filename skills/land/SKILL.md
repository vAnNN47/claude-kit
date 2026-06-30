---
name: land
description: Land a verified branch — fast-forward merge it into the trunk, prune it, and push to origin. The explicit merge+push step that /fire, /ship, and /forge deliberately refuse to do. Works in any repo (the claude-kit repo for skill branches, or an app repo for feature branches). Trigger on "/land", "land", "land the branch", "merge and push", "publish the branch", or "land <branch>".
argument-hint: "[branch]"
---

# land — merge the branch to trunk + push

The pipeline builds locally — `/fire` (app), `/forge` (skill), `/ship` (archive) **never merge or
push** (their rules say so). This is the one step that does, and only when you ask. It takes a
branch that's already verified/archived and **lands it on the trunk + remote**.

> **Why this exists:** local-only is the safe default, but it lets branches pile up unmerged (the
> queue drains into branches that never reach `main`). `land` is the deliberate, confirm-gated
> "publish it now" rung — `/ship`'s companion the backlog flagged as `[ship_merge_helper]`.

## Scope (any repo, one engine)

Operates on **the git repo of the current working directory** — no target arg. Run it from the
claude-kit repo to land a `chore/forge_*` skill branch; run it from an app repo to land a
`fix/`/`feat/`/`chore/` feature branch. Same mechanic both ways.

## Steps

1. **Resolve branch + trunk.** Branch = the `<branch>` arg, else the current branch. Trunk = the
   repo's default (`main` if it exists, else `master`). Refuse if branch **is** the trunk
   ("nothing to land"). Read `git rev-list --count trunk..branch` (commits to land) and
   `branch..trunk` (commits behind).

2. **Preflight (all must hold — stop with the reason if any fail):**
   - **Working tree clean** — no uncommitted changes (`git status --porcelain` empty). Dirty → stop.
   - **Fast-forwardable** — branch is `0` behind trunk (trunk is a strict ancestor). If behind, the
     merge can't ff: **stop and tell the user to rebase** (`git rebase trunk branch`) — `land` never
     creates a merge commit and never auto-rebases.
   - **Has something to land** — `trunk..branch` > 0. Zero → already landed, stop.

3. **Confirm gate.** Print the exact plan and **wait for explicit yes** before any write:
   ```
   land  <branch>  →  <trunk>   (ff, <N> commits)
   then push <trunk> → <remote>   (or "no remote — local only")
   then prune  <branch>  (+ list any other branches now fully merged into trunk)
   ```
   No confirmation → stop, change nothing.

4. **Merge (ff-only).** `git checkout <trunk>` → `git merge --ff-only <branch>`. If git rejects the
   ff (state changed since preflight), **stop** — never fall back to a merge commit.

5. **Push.** If an `origin` remote exists: `git push origin <trunk>` (the trunk ref only — never
   `--force`, never push other branches). No remote → skip, report "local only, no remote".

6. **Prune.** `git branch -d <branch>` (safe delete — only succeeds if merged). Offer to `-d` any
   other listed branches now fully merged into trunk; delete only the ones the user confirms. Never
   delete the trunk. Local branches only — never `git push --delete` a remote branch unless asked.

7. **Report.** Trunk's new HEAD, push result (or local-only), branches pruned, branches left.

## Rules

- **Fast-forward only — never a merge commit, never `--force`.** Keeps history linear (the kit's
  house style). A non-ff branch is the user's to rebase first; `land` refuses, it doesn't rewrite.
- **Confirm before any merge/push.** Merge+push is outward and hard to undo — step 3's gate is
  mandatory, same spirit as `/inbox` and `/inspect` writing only on confirm.
- **Push the trunk and nothing else.** No feature-branch pushes, no `--force`, no remote-branch
  deletes unless explicitly asked. Remote stays a fast-forward of what you reviewed.
- **One branch per call.** Batching = run `land` again. Keeps each publish isolated and revertible.
- **Never the default-branch auto-pilot.** `land` only pushes trunk because you invoked it on a
  verified branch and confirmed — it is not wired into `/fire`/`/forge`/`/ship`.

## Not this skill's job

- Building / fixing the code on the branch → `/fire` (app) · `/forge` (skill).
- Moving roadmap items to the archive → `/ship` (app) — run it *before* `land`, not here.
- Opening a pull request or code review → out of scope (ff-merge direct); a PR-based flow is a
  possible future variant, not this skill.
- Rebasing a branch that's behind trunk → the user does that, then re-runs `land`.
