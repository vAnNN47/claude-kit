---
name: skill-builder
description: Author a NEW skill the lean way — first study the structure of the top community skills (most-downloaded / top-rated on skills.sh), learn the common minimal pattern, then scaffold a single markdown SKILL.md with NO python/scripts unless the task genuinely needs them. Trigger on "/skill-builder <name>", "skill-builder <name>", "build a skill for <x>", "scaffold a skill", or "author a new skill". The opinionated lean twin of the official skill-creator.
argument-hint: "[skill-name]"
---

# skill-builder — author a lean skill, structure first

Make a new skill that earns its keep: a single `SKILL.md` in plain markdown, shaped by how the
best community skills are actually built — not by dumping every helper, python script, and
benchmark harness into the folder "just in case".

> **Why this exists:** the official `skill-creator` is a rigorous draft→eval engine, but it ships
> python scaffolding (`utils.py`, `aggregate_benchmark.py`) most skills never need. Most skills are
> a page of markdown. This skill keeps that the default and makes you *justify* every extra file.

Build for the claude-kit house style (terse, numbered Steps + Rules + a "Not this skill's job"
footer). `/forge` delegates here when a queued item is a new, judgment/glue skill.

## Steps

1. **Name + one-line intent.** Restate the skill in one sentence — "this skill ___" — to pin
   scope. Pick a `kebab-case` name; the folder `skills/<name>/` and the frontmatter `name:` must
   match exactly. Reject a name that overlaps an existing skill (check `skills/` first) — extend
   the existing one instead of cloning it.

2. **Study the field — structure ONLY, never bodies.** Fetch the top ~10–20 skills from
   **skills.sh** (sort by most-downloaded / top-rated). For each, look *only* at shape:
   - frontmatter fields used (name, description, argument-hint, anything else),
   - SKILL.md length (most are one screen),
   - whether they split a `references/` file or ship a `scripts/` dir — and *why* (was it real
     compute, or bloat?),
   - whether they ship python and whether it was actually needed.

   Distil the **common minimal pattern**. Do NOT copy prose, examples, or instructions from any
   skill — you are learning the skeleton, not the meat. If the web is unreachable, fall back to
   the in-repo exemplars (`inbox`, `fire`, `ship`) as the pattern.

3. **Decide the shape (default = one file).**
   - **SKILL.md only, markdown** — the default. Choose this unless you can name the reason not to.
   - **+ a `references/<topic>.md`** — only when there's >1 screen of *stable lookup* material
     (schemas, tables) that would bloat the main flow. Link it; don't inline it.
   - **+ a script** — only when the task needs deterministic compute prose can't express. Prefer
     `node`/`bash`; **avoid python**. Never add a helper/util/benchmark file the skill doesn't call.
   State the chosen shape and the justification for anything beyond a lone SKILL.md.

4. **Write SKILL.md, house style.** Frontmatter: `name` == folder; `description` a string with the
   trigger phrases; bracketed `argument-hint` quoted (e.g. `"[skill-name]"`). Body: a one-line
   purpose, an optional `> Why this exists:` blockquote, numbered **Steps**, a **Rules** list, and
   a closing **## Not this skill's job** footer that points at the neighbouring skills it is *not*.

5. **Author `TEST.md`.** Next to the SKILL.md, per the skill-tester spec (`trigger`, `setup`,
   `expect`, `guardrails`). If the skill can't be determinately sandboxed (needs live network or
   pure judgment), set `mode: load-check-only` and say why — don't fake a run.

6. **Load-check, then hand off.** Re-read the frontmatter (it must load: `name`==folder, strings,
   quoted bracket hint). Then tell the user to run **`/skill-tester <name>`** and, for a queued
   item, **`/forge`** to commit + archive it. Remind them to reload the editor window so the new
   skill registers.

## Rules

- **Markdown-first.** A lone SKILL.md is the goal; every extra file needs a stated reason.
- **No python by reflex.** Add a script only for real compute, and prefer node/bash. Never copy the
  skill-creator python scaffold.
- **Learn structure, don't plagiarise.** Study the top skills' skeleton; write your own words.
- **One skill per call.** Building two = run it twice.
- **Frontmatter must load.** `name` matches the folder, fields are strings, bracketed hint quoted —
  a skill that won't load is the failure this gate prevents.

## Not this skill's job

- Routing a brain-dump into the queue → `/inbox`.
- Taking a queued `[slug]` to commit + archive (branch, gates, README row) → `/forge` (it *calls*
  this skill to do the authoring).
- Proving the built skill behaves → `/skill-tester`.
- The rigorous draft→eval→optimize engine for objectively-scorable output → `skill-creator`.
