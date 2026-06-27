# claude-kit

Personal Claude Code plugin: a repeatable **idea → execution** pipeline, reusable
across every app.

## The three skills

| Skill | What it does |
|-------|--------------|
| `/inbox` | Capture a raw brain-dump, split into items, **route** each: app task → `roadmap.md`, tooling task → `SKILLS-TODO.md`, capability gap → flagged. Proposes first, writes after you confirm. |
| `/fire [id]` | Execute one roadmap item: branch → implement → tsc+lint → commit → move to `Done (unverified)`. One id, one branch, one commit. Local only. |
| `/ship` | On your confirm, move verified items from `Done (unverified)` to `archive/[year]/[mm-month].md`. Bookkeeping only. |

## The model

- **Run it → skill** (these). **Know it → instruction** (each app's `CLAUDE.md`).
  **Import it → component** (code in the app's `src/`).
- State triad per app: `roadmap.md` (now) · `archive/` (history) · `CLAUDE.md` (rules).
- The skills read each app's `CLAUDE.md → Workflow conventions` for the roadmap format,
  ID rules, lifecycle, and branch prefixes. They do **not** hardcode the format.

## Install (per device)

This repo is a Claude Code plugin. On each machine:

1. Clone it somewhere stable (e.g. `~/DEV/claude-kit`).
2. Add it as a plugin marketplace / local plugin in Claude Code (see Claude Code plugin
   docs for the current `plugin install` flow), pointing at this directory.
3. Verify with `/inbox` — it should resolve.

Conventions ride with each app (committed in the app's own `CLAUDE.md` + `roadmap.md`),
so cloning an app repo + installing this plugin = full flow on any device.

## Security

Logic only — **no secrets** in this repo. Keys/tokens live in gitignored
`settings.local.json`, never committed, never synced here.
