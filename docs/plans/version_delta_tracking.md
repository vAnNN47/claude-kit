---
id: version_delta_tracking
created: 2026-06-30
status: parked
---

# Plan — Version delta tracking: prod vs not-yet-released (`version_delta_tracking`)

## Idea

Diff "shipped to prod" vs "in main, not yet released" — `git log release..main`, or an `[Unreleased]`
CHANGELOG section. Mature teams track both directions: forward = "what's coming", and the delta
`release..main` *is* exactly "shipped vs not yet".

## Decision: PARKED (YAGNI)

**Not needed yet, and do not build it yet.** Apps currently auto-deploy `main` via Cloudflare Pages
(see app CLAUDE.md — `output: 'static'`, Pages serves `dist/`). There is **no release branch or tag**,
so there is no prod-vs-next delta to compute. Building version tooling now solves a problem that does
not exist.

## Trigger to un-park

Build the day a **staged release** actually exists: `main` = next, a `release` branch or tag = live.
Until deploys are staged, leave parked. Revisit then — not before.
