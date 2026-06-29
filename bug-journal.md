# Bug Journal — solved hardcore TOOLING bugs (postmortems)

Global, cross-app log of **nasty, non-obvious tooling / environment / build / plugin / editor**
bugs that took real digging — the kind worth never re-debugging from scratch. This lives in
**claude-kit** (the brain) so the recipe travels to every app on every machine. **App bugs do NOT
go here** — those live in each app's `roadmap.md`.

This is the tooling twin of `skills/rn-debug` Known Issues (which catalogues RN/Expo *code* mega-bugs).
The planned **`/lessons`** skill appends here after a hard win; the planned **`/refinery`** re-checks
whether a newer version already fixed an entry before you re-apply a workaround.

**Entry template:**
> ## YYYY-MM-DD — <one-line title>
> - **Symptom:** what you saw.
> - **Environment:** OS, client, tool/plugin + version.
> - **Wrong turns:** dead ends taken (so you don't repeat them).
> - **Root cause:** the real why (link repo issues/PRs).
> - **Fix:** exact change(s), file paths.
> - **Verify:** how you proved it.
> - **Prevention:** the rule/standard that would've caught it sooner.
> - **Caveat:** what can regress it.

---

## 2026-06-26 — `/caveman-stats` prints nothing (silent prompt-erase)

> Origin: CigTracker; the bug is in the global `caveman` plugin, so it's cross-app.

- **Symptom:** Typing `/caveman-stats` flashes a brief spinner, then the prompt **disappears with
  zero output** — no stats, no error.
- **Environment:** Claude Code in the **VSCode extension**, Windows 11; `caveman` marketplace
  plugin (`JuliusBrussee/caveman`, cache hash `25d22f864ad6`).
- **Wrong turns:**
  1. Assumed the command didn't exist → added `commands/caveman-stats.toml` (mirroring upstream
     PR #505). **CC ignores `.toml` commands** — no effect.
  2. Theorized from the Claude Code hooks docs instead of **checking the plugin repo's issues
     first** — the answer was already filed there.
- **Root cause (layered):**
  1. Plugin ships `/caveman-stats` as a `.toml` command + a `UserPromptSubmit` hook. Claude Code
     **does not discover `.toml` commands** (it wants `.md`) — upstream **#571** — and
     `.claude-plugin/plugin.json` is **missing `"skills": "./skills/"`**, so the `caveman-stats`
     `SKILL.md` never registers either — upstream **#569**. → `/caveman-stats` is an unknown command.
  2. The hook (`src/hooks/caveman-mode-tracker.js`) **does** match `/caveman-stats` and returns
     `{decision:"block", reason:<stats>}`. On `UserPromptSubmit`, `decision:"block"` **erases the
     prompt**; in the **VSCode client the `reason` is not rendered** → prompt vanishes, nothing
     prints. (The terminal client shows the reason; VSCode doesn't.) The reader script itself
     (`src/hooks/caveman-stats.js`) **always worked** when run directly.
- **Fix:**
  1. A project skill `caveman-stats/SKILL.md` — a CC-discovered command that runs the plugin's
     `src/hooks/caveman-stats.js` and prints its stdout.
  2. Disabled the hook's stats intercept in the **active cache copy**
     (`plugins/cache/caveman/caveman/25d22f864ad6/src/hooks/caveman-mode-tracker.js`):
     `if (statsMatch)` → `if (false && statsMatch)`, so `/caveman-stats` falls through to the skill
     instead of being block-erased.
- **Verify:** `/caveman-stats` prints the stats block. Hook harness: `BLOCKED=false` for bare,
  `--all`, and VSCode-`<command-name>`-wrapped forms.
- **Prevention:** *"Never guess — check the source first; on a bug search the repo's OPEN **and**
  CLOSED issues + PRs first."* All four relevant items (#505, #563, #569, #571) were already filed.
- **Caveat:** the cache edit **reverts on plugin reinstall/update** — reapply the one-line disable.
  A project/global skill survives.
- **Upstream refs (read-only — we don't post to others' repos):** #505 (`.toml`, wrong format),
  #563 (empty transcript), #569 (skills not registered), #571 (`.toml` vs `.md`).
