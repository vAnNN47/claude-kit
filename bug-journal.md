# Bug Journal — solved hardcore TOOLING bugs (postmortems)

Global, cross-app log of **nasty, non-obvious tooling / environment / build / plugin / editor**
bugs that took real digging — the kind worth never re-debugging from scratch. This lives in
**claude-kit** (the brain) so the recipe travels to every app on every machine. **App bugs do NOT
go here** — those live in each app's `roadmap.md`.

This is the tooling twin of `skills/rn-debug` Known Issues (which catalogues RN/Expo *code* mega-bugs).
The **`/lessons`** skill appends here after a hard win; the planned **`/refinery`** re-checks
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

## 2026-07-02 — iOS dev client can't load Metro over Tailscale (ATS blocks HTTP to CGNAT IP)

> Origin: ManageMeRN; applies to any Expo app + remote dev over Tailscale.

- **Symptom:** Dev client on iPhone loads fine from LAN (`http://10.0.0.3:8081`) but from the
  Tailscale IP fails: *"Could not connect to development server"*, then once connected:
  *"The resource could not be loaded because the App Transport Security policy requires the
  use of a secure connection."* (`http://100.119.143.6:8081`).
- **Environment:** Metro on Windows 11; Expo SDK 56 (`@expo/cli` 56.1.16, `expo-dev-client`
  ~56.0.21); iPhone 11 Pro (iOS, Tailscale app); tailnet `tail4e0f2c.ts.net`.
- **Wrong turns:**
  1. Suspected Windows firewall / Metro binding — both fine (node.exe allowed on Private,
     Tailscale iface classed Private, Metro listens on `::`; `/status` reachable from every peer).
  2. Chased "wrong URL" — dev client was silently reconnecting to a **stale recents entry**
     (`10.0.0.3`) instead of the freshly entered host. Delete recents when switching hosts.
  3. First fix: `NSAppTransportSecurity.NSAllowsArbitraryLoads=true` in app.json + EAS rebuild.
     Works, but disables ATS app-wide (ship risk, Apple review flag) and costs a dev-client
     rebuild. Reverted in favor of HTTPS.
- **Root cause:** iOS ATS blocks cleartext HTTP to non-local addresses. Private LAN ranges
  (`10.x`/`192.168.x`) pass via the local-networking exemption; **Tailscale's CGNAT range
  (`100.64.0.0/10`) does not count as local** → HTTP to `100.x` is blocked. Only bites when
  off-LAN, so LAN testing hides it.
- **Fix (no app rebuild):** serve Metro over real HTTPS via Tailscale:
  1. `tailscale serve --bg 8081` on the Metro machine (one-time tailnet approval link on first
     run) → proxies `https://desktop-5tq49n1.tail4e0f2c.ts.net` → `127.0.0.1:8081` with a valid
     Let's Encrypt cert. Survives reboots; disable with `tailscale serve --https=443 off`.
  2. Start Metro with the proxy URL so the **manifest also advertises HTTPS** (else follow-up
     bundle/asset requests fall back to `http://100.x` and ATS kills them):
     ```powershell
     $env:EXPO_PACKAGER_PROXY_URL='https://desktop-5tq49n1.tail4e0f2c.ts.net'
     npx expo start --dev-client
     ```
     (`EXPO_PACKAGER_PROXY_URL` is honored by `@expo/cli` — `build/src/start/server/UrlCreator.js`.)
  3. Phone: Tailscale ON → dev client → enter `https://desktop-5tq49n1.tail4e0f2c.ts.net`.
- **Verify:** `https://…ts.net/status` → `packager-status:running`; manifest `launchAsset.url`
  + `hostUri` all `https://…ts.net` with `dev=true`; phone loads the bundle from LAN and LTE.
- **Prevention:** remote iOS dev rule — HTTP only works same-LAN; anything via VPN/CGNAT needs
  HTTPS (or an ATS exception in the build). Mode switch lives in env vars:
  `REACT_NATIVE_PACKAGER_HOSTNAME=<ip>` = plain-HTTP mode (LAN), `EXPO_PACKAGER_PROXY_URL=<https url>`
  = proxy mode (Tailscale). Don't mix stale values — one terminal, set the one you mean.
- **Caveat:** proxy 502 = Metro not running (serve itself is fine — start Metro first).
  `EXPO_PACKAGER_PROXY_URL` must be set in every Metro terminal (or persisted with `setx`).
  Dev client recents cache old hosts — stale entries mimic misconfiguration.
- **Search terms:** expo dev client "App Transport Security" tailscale · EXPO_PACKAGER_PROXY_URL ·
  tailscale serve https metro 8081 · NSAllowsLocalNetworking CGNAT 100.64.

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
