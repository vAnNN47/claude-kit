# claude-kit

My personal toolkit for [Claude Code](https://claude.com/claude-code). Two jobs:
1. Turn messy ideas into shipped code, the same way every time.
2. Stop me re-solving the same React Native bugs that eat hours.

Plain words below — you don't need to be a programmer to follow it.

## The skills (what each one does)

| Skill | What it does | When you use it |
|-------|--------------|-----------------|
| `/inbox` | Dump messy ideas; it sorts each into the right to-do list. | Brain full, need to capture. |
| `/roadmap` | Owns the roadmap layout: `init` picks a style for a new project, `convert` flips an existing one between the two styles (`section` ↔ `flat`). | New project, or switching layout. |
| `/fire` | Takes ONE to-do all the way: branch → build → check → save. | Ready to build a queued item. |
| `/ship` | Files finished, tested work into the history log. | A fired item is verified. |
| `/forge` | Like `/fire`, but builds new **skills** instead of app features. | Draining the skills backlog. |
| `/skill-tester` | Proves a skill actually works before it ships. | Runs automatically inside `/forge`. |
| `/skill-builder` | Builds a NEW skill the lean way — studies the top skills' shape, writes one markdown file, no python bloat. | Creating a brand-new skill. |
| `/polish` | `check` lists type/lint/format problems; `run` fixes the safe ones. | Tidy the tree before a commit. |
| `/inspect` | Audits the workforce itself (or, with `app`, the current app): finds where the rules drifted from reality, logs each to a de-duped ledger. | Checking the system is still sound. |
| `/land` | Lands a finished branch: fast-forwards it onto the trunk, deletes it, pushes. The one step that touches the remote — always asks first. | Ready to publish a verified branch. |
| `/rn-debug` | Hunts "works on iPhone, blank on Android" bugs without flailing. | A screen breaks on one platform. |
| `/refinery` *(planned)* | Before hand-coding a fix, checks if a package or a newer version already solved it. | Starting on a known-hard problem. |
| `/lessons` *(planned)* | After beating a nasty bug, saves the recipe so you never re-fight it. | Right after a hard win. |

## The flow

```
idea  →  /inbox  →  /fire   →  /ship   →  /land   →  remote
                    (/forge for skills)   (archive)   (push)
```

That's it. Capture → do one thing → file it away → publish it. One item, one branch, one save.
Everything stays local until `/land` — the only step that touches the remote, and only when you say so.

## Hit a wall? (the 3-hour-bug rule)

A bug that works on iPhone but breaks on Android can swallow an afternoon. Don't thrash. Instead:

1. **Run `/rn-debug`** — it isolates the cause step by step (colored boxes, one change at a time, read logs first) instead of guessing.
2. **Check Known Issues FIRST** (in [`skills/rn-debug/SKILL.md`](skills/rn-debug/SKILL.md)) — the big bugs already cracked and written down:
   - **Blank Android list** — a `refreshControl` wrapped in a custom component makes the list show nothing. Fix: pass a direct `<RefreshControl>`.
   - **RTL (Hebrew/Arabic) input kills Android scroll** (React Native bug #16206) — fix: split by platform (`writingDirection` on Android, `textAlign` on iOS).
3. **Solved a NEW one?** Run `/lessons` so it joins the list — next time it's a 5-minute lookup, not 3 hours.

## Install (on a new machine)

```bash
git clone <this-repo> ~/.claude/skills/claude-kit
cd ~/.claude/skills/claude-kit
npx skills add            # restores marketplace skills from skills-lock.json
export PATH="$HOME/.claude/skills/claude-kit/bin:$PATH"                  # bin/ helpers on PATH
source "$HOME/.claude/skills/claude-kit/shell/fire.bash"                 # `fire <slug>` + Tab-complete (bash/zsh)
```

PowerShell: add to your `$PROFILE` instead —
```powershell
. "$env:USERPROFILE\.claude\skills\claude-kit\shell\fire.ps1"
```

Both source the same logic from the repo, so an edit in `shell/` reaches every cloned device on the
next shell reload — no per-machine copy to keep in sync.

Then reload your editor. Conventions ride along with each app (in that app's `CLAUDE.md`), so cloning an app + this toolkit = the full flow on any device.

`bin/` holds standalone terminal helpers (no LLM call) that ride along with the skills — currently
`roadmap-ids` (list every roadmap id, for `/fire <id>` / `/ship <id>`; see
[`skills/roadmap/SKILL.md`](skills/roadmap/SKILL.md)). `shell/` holds shell-rc snippets you `source`:
`fire.ps1` / `fire.bash` give a `fire <slug>` command that launches `/fire` with **Tab-completed
roadmap slugs** (type `fire comfy<Tab>`) — read from the nearest `roadmap.md`.

## The model (1 line)

**Run it → skill** (these). **Know it → instruction.** **Import it → component** (code in the app's `src/`).

Instructions split by reach:
- **Global / cross-app** (every project) live here in claude-kit, loaded by the skills:
  [`STANDARDS.md`](STANDARDS.md) (engineering rules: no-`any`, never-guess, LSP-over-grep, verify gate,
  git hygiene — env-aware), the [`rn-debug` Known Issues](skills/rn-debug/SKILL.md) (portable RN/Expo
  mega-bug registry), and [`bug-journal.md`](bug-journal.md) (solved tooling/plugin postmortems).
- **App-specific** (one project's stack/conventions) live in **that app's `CLAUDE.md`**.

## Security

Logic only — **no secrets**. Keys/tokens live in gitignored `settings.local.json`, never committed.
