# Archive — July 2026

## 2026-07-01
- [roadmap_ids_cli] (tweak) — `bin/roadmap-ids [path]`: prints every roadmap `[id]` slug, one per
  line, in file order; works unchanged for both `section`/`flat` tactics. Documented in
  `skills/roadmap/SKILL.md` + README install (`PATH` export). Functional test: ran against
  Leetbeck's live `roadmap.md` (with + without explicit path arg), output matched the file's open
  ids exactly. → chore/forge_roadmap_ids_cli
