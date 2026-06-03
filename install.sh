#!/usr/bin/env bash

# Symlink commands (and any hand-written skills) into ~/.claude.
# Third-party skills/mcp/plugins are install-only — see their third-party.md.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="${HOME}/.claude"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "${dst}")"
  ln -sfn "${src}" "${dst}"
  echo "linked ${dst} -> ${src}"
}

# commands/*.md -> ~/.claude/commands/
for f in "${REPO}"/commands/*.md; do
  [[ -e "${f}" ]] || continue
  link "${f}" "${CLAUDE}/commands/$(basename "${f}")"
done

# hand-written skill folders (each has SKILL.md) -> ~/.claude/skills/
for d in "${REPO}"/skills/*/; do
  [[ -f "${d}/SKILL.md" ]] || continue
  link "${d%/}" "${CLAUDE}/skills/$(basename "${d}")"
done

echo "done!"
