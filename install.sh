#!/usr/bin/env bash

# Symlink commands (and any hand-written skills) into ~/.claude.
# Third-party skills/mcp/plugins are install-only — see their third-party.md.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="${HOME}/.claude"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "${dst}")"
  # Guard against self-symlink: if dst's parent is itself a symlink back into
  # the repo, dst resolves to src and `ln` would replace the real file with a
  # link to itself. Skip when both resolve to the same path.
  local real_src real_dst
  real_src="$(cd "$(dirname "${src}")" && pwd -P)/$(basename "${src}")"
  real_dst="$(cd "$(dirname "${dst}")" && pwd -P)/$(basename "${dst}")"
  if [[ "${real_src}" == "${real_dst}" ]]; then
    echo "skip (already resolves to source) ${dst}"
    return
  fi
  ln -sfn "${src}" "${dst}"
  echo "linked ${dst} -> ${src}"
}

# commands/ -> ~/.claude/commands (whole-dir symlink; new commands appear automatically)
link "${REPO}/commands" "${CLAUDE}/commands"

# hand-written skill folders (each has SKILL.md) -> ~/.claude/skills/
# (per-folder: third-party skills live in the same real dir)
for d in "${REPO}"/skills/*/; do
  [[ -f "${d}SKILL.md" ]] || continue
  link "${d%/}" "${CLAUDE}/skills/$(basename "${d}")"
done

# statusline script -> ~/.claude/ (referenced by settings.json statusLine)
link "${REPO}/config/statusline-command.sh" "${CLAUDE}/statusline-command.sh"

echo "done!"
