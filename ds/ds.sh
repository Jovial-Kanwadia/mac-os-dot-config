#!/usr/bin/env bash
# ds.sh — Handmade doc search
# ~/.config/ds/ds.sh
#
# dedoc search output format:
#   5109  slices/index        ← page slug
#   4834  #SliceAt            ← fragment: anchor on parent page
#
# Fragment behaviour:
#   Opens the FULL parent page in less, jumped to the anchor section.
#   User can scroll freely up and down from there.

# ── Colors ────────────────────────────────────────────────────────────────────
CYAN='\033[0;36m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

# ── 1. Language picker ────────────────────────────────────────────────────────
SELECTED_LANG=$(printf 'cpp\nrust\ngo\npython\njavascript\nlua' \
  | fzf --prompt="󰗚  Docset › " \
        --height=40% --reverse --no-info)
[[ -z "$SELECTED_LANG" ]] && exit 0

# ── 2. Single fetch — reused for fzf AND fragment resolution ─────────────────
RAW=$(dedoc search "$SELECTED_LANG" "" 2>/dev/null)
if [[ -z "$RAW" ]]; then
  echo -e "${RED}✗ dedoc returned nothing for '$SELECTED_LANG'${NC}" >&2
  exit 1
fi

# ── 3. Interactive picker ─────────────────────────────────────────────────────
RESULT=$(printf '%s\n' "$RAW" \
  | fzf --prompt=" $SELECTED_LANG › " \
        --height=80% --reverse --no-info)
[[ -z "$RESULT" ]] && exit 0

# ── 4. Slug resolution ────────────────────────────────────────────────────────
resolve_slug() {
  local result="$1"
  local token
  token=$(awk '{print $NF}' <<< "$result")

  # Plain slug — use directly
  if [[ "$token" != \#* ]]; then
    printf '%s' "$token"
    return 0
  fi

  # Fragment — find parent via proximity (nearest preceding non-# token)
  local anchor="${token#\#}"
  local frag_lineno
  frag_lineno=$(grep -nF "$result" <<< "$RAW" | head -1 | cut -d: -f1)

  if [[ -n "$frag_lineno" ]]; then
    local parent_slug
    parent_slug=$(head -n "$frag_lineno" <<< "$RAW" \
      | awk '{ t = $NF; if (t !~ /^#/) last = t } END { print last }')

    if [[ -n "$parent_slug" ]]; then
      printf '%s#%s' "$parent_slug" "$anchor"
      return 0
    fi
  fi

  printf '%s' "$token"
  return 1
}

SLUG=$(resolve_slug "$RESULT")

if [[ -z "$SLUG" || "$SLUG" == \#* ]]; then
  echo -e "${RED}✗ Could not resolve slug for:${NC} '$RESULT'" >&2
  exit 1
fi

# ── 5. Open ───────────────────────────────────────────────────────────────────
# Split slug into base page and optional anchor.
#   "slices/index"           → no anchor, open as-is
#   "slices/index#SliceExpr" → open full page, jump to SliceExpr
#
BASE_SLUG="${SLUG%%\#*}"   # everything before '#'  e.g. "slices/index"
ANCHOR="${SLUG##*\#}"      # everything after  '#'  e.g. "SliceExpr"

if [[ "$BASE_SLUG" == "$ANCHOR" ]]; then
  # No '#' in slug — plain page open
  echo -e "${CYAN}●${NC} ${DIM}$SELECTED_LANG${NC} › ${CYAN}$BASE_SLUG${NC}"
  dedoc open "$SELECTED_LANG" "$BASE_SLUG" | less -R
else
  # Fragment selected — open FULL parent page, land on the anchor
  echo -e "${CYAN}●${NC} ${DIM}$SELECTED_LANG${NC} › ${CYAN}$BASE_SLUG ${DIM}#${ANCHOR}${NC}"
  dedoc open "$SELECTED_LANG" "$BASE_SLUG" | less -R +"/$ANCHOR"
fi
