# claude-kit terminal helper: `fire <slug>` with Tab-completed roadmap slugs.
#
# Source this from your shell rc (~/.bashrc, or ~/.zshrc on macOS):
#   source "$HOME/.claude/skills/claude-kit/shell/fire.bash"
# Works in bash and zsh (zsh gets the bash-style completer via bashcompinit).
#
# Logic lives here (in the repo) so every cloned device behaves the same and
# edits propagate on the next shell reload. `fire <slug>` launches Claude Code
# running /fire on that roadmap id; Tab completes the slug from the nearest
# roadmap.md (current dir or any parent).

fire() { claude "/fire $1"; }

_fire_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local dir="$PWD" file=""
  while [[ -n "$dir" ]]; do
    if [[ -f "$dir/roadmap.md" ]]; then file="$dir/roadmap.md"; break; fi
    [[ "$dir" == "/" ]] && break
    dir="$(dirname "$dir")"
  done
  [[ -z "$file" ]] && return 0
  local slugs
  slugs="$(grep -oE '^[[:space:]]*-[[:space:]]*\[[a-zA-Z0-9_]+\]' "$file" | sed -E 's/.*\[(.+)\]$/\1/')"
  COMPREPLY=($(compgen -W "$slugs" -- "$cur"))
}
# Register the completer. bash has `complete` natively; zsh (macOS default) needs
# bashcompinit to provide it. Guard so sourcing never errors on either shell.
if [ -n "${ZSH_VERSION:-}" ]; then
  autoload -Uz bashcompinit 2>/dev/null && bashcompinit 2>/dev/null
fi
complete -F _fire_complete fire 2>/dev/null
