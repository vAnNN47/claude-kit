# claude-kit

Personal Claude Code plugin: a repeatable **idea → execution** pipeline, reusable
across every app.

## The four skills

| Skill | What it does |
|-------|--------------|
| `/inbox` | Capture a raw brain-dump, split into items, **route** each: app task → `roadmap.md`, tooling task → `SKILLS-TODO.md`, capability gap → flagged. Proposes first, writes after you confirm. |
| `/fire [id]` | Execute one roadmap item: branch → implement → tsc+lint → commit → move to `Done (unverified)`. One id, one branch, one commit. Local only. |
| `/ship` | On your confirm, move verified items from `Done (unverified)` to `archive/[year]/[mm-month].md`. Bookkeeping only. |
| `/forge [slug]` | The twin of `/fire` for the **tooling** queue: drain one `SKILLS-TODO.md` item — branch (in this repo) → build (delegating new testable skills to `skill-creator`) → load-check → commit → archive the line. One slug, one branch, one commit. Local only. |

## The model

- **Run it → skill** (these). **Know it → instruction** (each app's `CLAUDE.md`).
  **Import it → component** (code in the app's `src/`).
- State triad per app: `roadmap.md` (now) · `archive/` (history) · `CLAUDE.md` (rules).
- The skills read each app's `CLAUDE.md → Workflow conventions` for the roadmap format,
  ID rules, lifecycle, and branch prefixes. They do **not** hardcode the format.

## Install (per device) — skills-directory auto-load

This repo is a Claude Code plugin loaded via the skills directory (no marketplace, no
`/plugin install`). It auto-loads every session as `claude-kit@skills-dir`.

On each machine, clone it into the Claude skills directory:

```bash
git clone <your-remote> ~/.claude/skills/claude-kit
# Windows: C:/Users/<you>/.claude/skills/claude-kit
```

Restart Claude Code, then verify with `/claude-kit:inbox` (plugin skills are namespaced).
Update later with `git pull` in that directory.

Conventions ride with each app (committed in the app's own `CLAUDE.md` + `roadmap.md`),
so cloning an app repo + this plugin = full flow on any device.

## Security

Logic only — **no secrets** in this repo. Keys/tokens live in gitignored
`settings.local.json`, never committed, never synced here.
