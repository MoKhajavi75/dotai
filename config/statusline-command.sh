#!/bin/bash

# Claude Code statusline — three lines:
#   1. project/dir [branch] | +added/-removed | ↑ahead↓behind
#   2. model | $cost
#   3. CTX % | 5h: % (reset) | 7d: % (reset)

exec 2>/dev/null

input=$(cat)

# Non-whitespace delimiter (ASCII unit separator) so empty fields are preserved
# by `read` — a whitespace IFS like tab collapses adjacent delimiters.
US=$(printf '\037')
parsed=$(printf '%s' "${input}" | jq -r --arg us "${US}" '[
  (.model.display_name),
  (.workspace.current_dir // .cwd // ""),
  ((.context_window.current_usage.input_tokens // 0)
   + (.context_window.current_usage.cache_creation_input_tokens // 0)
   + (.context_window.current_usage.cache_read_input_tokens // 0)),
  (.context_window.context_window_size // 0),
  (.rate_limits.five_hour.used_percentage // null | if . then (100 - . | round) else "null" end),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // null | if . then (100 - . | round) else "null" end),
  (.rate_limits.seven_day.resets_at // ""),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0),
  (.cost.total_cost_usd // 0)

] | map(tostring) | join($us)')

IFS="${US}" read -r model cwd used_tokens window_size five_pct five_reset seven_pct seven_reset lines_added lines_removed cost_usd <<EOF
${parsed}
EOF

RESET="\033[0m"
DIM="\033[2m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[94m"
MAGENTA="\033[95m"
CYAN="\033[96m"
WHITE="\033[97m"

# Compute once, reused by format_reset
now=$(date +%s)

# Format seconds remaining as "4h 23m" or "1d 21h"
format_reset() {
  local ts="$1"
  [[ -z "${ts}" ]] && return
  local epoch diff
  # resets_at is a Unix epoch integer
  epoch=$(printf '%s' "${ts}" | tr -dc '0-9')
  [[ -z "${epoch}" ]] && return
  diff=$(( epoch - now ))
  [[ "${diff}" -le 0 ]] && return
  local mins=$(( diff / 60 ))
  local hours=$(( mins / 60 ))
  local days=$(( hours / 24 ))
  if [[ "${days}" -ge 1 ]]; then
    printf "%dd%dh" "${days}" $(( hours % 24 ))
  elif [[ "${hours}" -ge 1 ]]; then
    printf "%dh%dm" "${hours}" $(( mins % 60 ))
  else
    printf "%dm" "${mins}"
  fi
}

# Last two dir of PWD
project_info="$(basename "$(dirname "${cwd}")")/$(basename "${cwd}")"

# Git branch (single git call; empty if not a repo)
git_branch=$(git -C "${cwd}" rev-parse --abbrev-ref HEAD 2>/dev/null)
[[ "${git_branch}" = "HEAD" ]] && git_branch=$(git -C "${cwd}" rev-parse --short HEAD 2>/dev/null)

# Ahead/behind vs upstream (empty if no upstream)
git_track=""
if [[ -n "${git_branch}" ]]; then
  counts=$(git -C "${cwd}" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)
  if [[ -n "${counts}" ]]; then
    behind=${counts%%[	 ]*}
    ahead=${counts##*[	 ]}
    track=""
    [[ "${ahead}" -gt 0 ]] 2>/dev/null && track="${track}↑${ahead}"
    [[ "${behind}" -gt 0 ]] 2>/dev/null && track="${track}↓${behind}"
    [[ -n "${track}" ]] && git_track="${MAGENTA}${track}${RESET}"
  fi
fi

ctx_pct=0
if [[ "${window_size}" -gt 0 ]] 2>/dev/null; then
  ctx_pct=$(awk -v u="${used_tokens}" -v t="${window_size}" 'BEGIN { printf "%d", 100 - (u/t)*100 }')
fi
if [[ "${ctx_pct}" -le 15 ]] 2>/dev/null; then
  ctx_color="${RED}"
elif [[ "${ctx_pct}" -le 30 ]] 2>/dev/null; then
  ctx_color="${YELLOW}"
else
  ctx_color="${GREEN}"
fi
context_part="${WHITE}CTX:${RESET} ${ctx_color}${ctx_pct}%${RESET}"

usage_color() {
  local pct="$1"
  if [[ "${pct}" -le 10 ]] 2>/dev/null; then printf "%s" "${RED}"
  elif [[ "${pct}" -le 30 ]] 2>/dev/null; then printf "%s" "${MAGENTA}"
  else printf "%s" "${BLUE}"
  fi
}

if [[ "${five_pct}" != "null" ]] && [[ -n "${five_pct}" ]]; then
  color=$(usage_color "${five_pct}")
  reset_str=$(format_reset "${five_reset}")
  if [[ -n "${reset_str}" ]]; then
    five_part="${WHITE}5h:${RESET} ${color}${five_pct}%${RESET} ${DIM}(${reset_str})${RESET}"
  else
    five_part="${WHITE}5h:${RESET} ${color}${five_pct}%${RESET}"
  fi
else
  five_part="${WHITE}5h:${RESET} ${DIM}--${RESET}"
fi

if [[ "${seven_pct}" != "null" ]] && [[ -n "${seven_pct}" ]]; then
  color=$(usage_color "${seven_pct}")
  reset_str=$(format_reset "${seven_reset}")
  if [[ -n "${reset_str}" ]]; then
    seven_part="${WHITE}7d:${RESET} ${color}${seven_pct}%${RESET} ${DIM}(${reset_str})${RESET}"
  else
    seven_part="${WHITE}7d:${RESET} ${color}${seven_pct}%${RESET}"
  fi
else
  seven_part="${WHITE}7d:${RESET} ${DIM}--${RESET}"
fi

# Lines added/removed this session
lines_part=""
if [[ "${lines_added:-0}" -gt 0 ]] 2>/dev/null || [[ "${lines_removed:-0}" -gt 0 ]] 2>/dev/null; then
  lines_part="${GREEN}+${lines_added}${RESET}${DIM}/${RESET}${RED}-${lines_removed}${RESET}"
fi

cost_part=""
if [[ -n "${cost_usd}" ]]; then
  cost_str=$(awk -v c="${cost_usd}" 'BEGIN { printf "%.2f", c }')
  [[ "${cost_str}" != "0.00" ]] && cost_part="${DIM}\$${RESET}${YELLOW}${cost_str}${RESET}"
fi

SEP="${DIM}|${RESET}"

# Join non-empty args with SEP; prints nothing if all empty
join_parts() {
  local out="" p
  for p in "$@"; do
    [[ -z "${p}" ]] && continue
    if [[ -z "${out}" ]]; then out="${p}"; else out="${out} ${SEP} ${p}"; fi
  done
  printf '%b' "${out}"
}

if [[ -n "${git_branch}" ]]; then
  loc_part="${WHITE}${project_info}${RESET} ${DIM}[${RESET}${CYAN}${git_branch}${RESET}${DIM}]${RESET}"
else
  loc_part="${WHITE}${project_info}${RESET}"
fi

# Line 1 — location [branch] | +/- | ↑↓
line1=$(join_parts "${loc_part}" "${lines_part}" "${git_track}")
# Line 2 — model | $cost
line2=$(join_parts "${WHITE}${model}${RESET}" "${cost_part}")
# Line 3 — CTX | 5h | 7d
line3=$(join_parts "${context_part}" "${five_part}" "${seven_part}")

# Print only non-empty lines; always terminate with \0 separator
out=""
for l in "${line1}" "${line2}" "${line3}"; do
  [[ -n "${l}" ]] && out="${out}${l}\n"
done
printf "%b\0" "${out}"
