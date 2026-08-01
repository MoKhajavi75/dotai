#!/usr/bin/env bash

# Install the statusline script into ~/.claude, where settings.json expects it.
#
#   from a clone:  ./config/install.sh
#                  symlinks, so edits in the repo are live
#
#   remote:        curl -fsSL https://raw.githubusercontent.com/MoKhajavi75/dotai/main/config/install.sh | bash
#                  downloads a copy
#
# Anything already at the destination is moved to statusline-command.sh.bak.

set -euo pipefail

RAW="${RAW:-https://raw.githubusercontent.com/MoKhajavi75/dotai/main/config/statusline-command.sh}"
CLAUDE="${HOME}/.claude"
DST="${CLAUDE}/statusline-command.sh"

# Local copy if this script is running from a clone; empty when piped from curl.
SRC=""
if [[ -f "${BASH_SOURCE[0]:-}" ]]; then
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  [[ -f "${dir}/statusline-command.sh" ]] && SRC="${dir}/statusline-command.sh"
fi

mkdir -p "${CLAUDE}"

if [[ -L "${DST}" && -n "${SRC}" && "$(readlink "${DST}")" == "${SRC}" ]]; then
  echo "already linked: ${DST} -> ${SRC}"
  exit 0
fi

# Preserve whatever is there. A second run overwrites the previous .bak, so a
# stale backup never shadows the one that matters.
if [[ -e "${DST}" || -L "${DST}" ]]; then
  mv -f "${DST}" "${DST}.bak"
  echo "backed up: ${DST} -> ${DST}.bak"
fi

if [[ -n "${SRC}" ]]; then
  ln -s "${SRC}" "${DST}"
  echo "linked: ${DST} -> ${SRC}"
else
  curl -fsSL "${RAW}" -o "${DST}"
  chmod +x "${DST}"
  echo "downloaded: ${RAW} -> ${DST}"
fi

# The script only runs if settings.json points at it.
if [[ ! -f "${CLAUDE}/settings.json" ]] || ! grep -q '"statusLine"' "${CLAUDE}/settings.json"; then
  cat <<'EOF'

Add this to ~/.claude/settings.json:

  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
EOF
fi

echo "done!"
