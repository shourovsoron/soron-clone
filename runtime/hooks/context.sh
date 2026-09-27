#!/bin/bash
# Soron Digital Clone: SessionStart context script (Phase 4.5).
# Prints a short orientation block (state and pointers only) into the session context.
# It is not a permission layer: it cannot allow, ask or block anything, and it never
# changes files. It reads only: its stdin (source, cwd), the leading headers of
# memory/projects/*.md, tasks/tasks.md, tasks/approvals.md, and read-only git state of
# the Clone. No network, no transcripts, no project files, no secrets. Always exits 0.

MAX_LINES=25
MAX_CHARS=2048
STALE_DAYS=30
MAX_TASKS=8
NL=$'\n'

if locale -a 2>/dev/null | grep -qx 'en_US.UTF-8'; then export LC_ALL=en_US.UTF-8; else export LC_ALL=C; fi
trap 'exit 0' EXIT

notice() {
  printf '[Soron Clone context unavailable: %s. Read ~/soron-clone/runtime/PROTOCOL.md before acting.]\n' "$1"
  exit 0
}

# ---------------------------------------------------------------- setup
SELF_DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd -P) || notice "cannot locate the script"
REAL_CLONE=$(cd "$SELF_DIR/../.." 2>/dev/null && pwd -P) || notice "cannot locate the Clone"
ROOT=$REAL_CLONE
JQ=/usr/bin/jq
TODAY=$(date +%s)
TEST_MODE=0

# Test-only switches: honoured only when CLONE_CONTEXT_ROOT resolves inside runtime/tests/fixtures/.
if [ -n "${CLONE_CONTEXT_ROOT:-}" ]; then
  FIX=$(cd "$CLONE_CONTEXT_ROOT" 2>/dev/null && pwd -P)
  case "$FIX" in
    "$REAL_CLONE/runtime/tests/fixtures/"?*)
      ROOT=$FIX; TEST_MODE=1
      if [ "${CLONE_CONTEXT_NO_JQ:-}" = 1 ]; then JQ=/nonexistent/jq; fi
      if [ -n "${CLONE_CONTEXT_TODAY:-}" ]; then
        TODAY=$(date -j -f '%Y-%m-%d %H:%M:%S' "$CLONE_CONTEXT_TODAY 12:00:00" +%s 2>/dev/null || date +%s)
      fi ;;
  esac
fi

# ---------------------------------------------------------------- input
[ -x "$JQ" ] || notice "jq not available"
INPUT=$(cat 2>/dev/null)
printf '%s' "$INPUT" | "$JQ" -e 'type == "object"' >/dev/null 2>&1 || notice "malformed hook input"
EVENT=$(printf '%s' "$INPUT" | "$JQ" -r '.hook_event_name // "SessionStart" | strings' 2>/dev/null)
[ "$EVENT" = SessionStart ] || exit 0
CWD=$(printf '%s' "$INPUT" | "$JQ" -r '.cwd // "" | strings' 2>/dev/null)
SOURCE=$(printf '%s' "$INPUT" | "$JQ" -r '.source // "" | strings' 2>/dev/null)
case "$SOURCE" in startup|resume|clear|compact) ;; *) SOURCE=unknown ;; esac
case "$CWD" in /*) ;; *) CWD="" ;; esac
[ "$CWD" = "/" ] || CWD=${CWD%/}

# ---------------------------------------------------------------- helpers
OUT=""
add() { OUT="$OUT$1$NL"; }
expand_home() {
  case "$1" in
    "~") [ -n "${HOME:-}" ] && printf '%s' "$HOME" ;;
    "~/"*) [ -n "${HOME:-}" ] && printf '%s/%s' "$HOME" "${1#\~/}" ;;
    /*) printf '%s' "$1" ;;
  esac
}
show_path() {
  if [ -n "${HOME:-}" ]; then
    case "$1" in "$HOME") printf '~'; return ;; "$HOME"/*) printf '~/%s' "${1#"$HOME"/}"; return ;; esac
  fi
  printf '%s' "$1"
}
header_field() {   # $1 file, $2 key: value from the leading --- header only
  awk -v k="$2" 'NR == 1 { if ($0 != "---") exit; next }
                 $0 == "---" { exit }
                 index($0, k ": ") == 1 { print substr($0, length(k) + 3); exit }' "$1" 2>/dev/null
}
short() { if [ ${#1} -gt 60 ]; then printf '%s…' "${1:0:60}"; else printf '%s' "$1"; fi; }
join_ids() { if [ -n "$1" ]; then printf '%s' "$1" | tr '\n' ',' | sed -e 's/,$//' -e 's/,/, /g'; else printf 'none'; fi; }

PROJ="$ROOT/memory/projects"
TASKS="$ROOT/tasks/tasks.md"
APPROVALS="$ROOT/tasks/approvals.md"

# ---------------------------------------------------------------- header and Clone state
add "[Soron Clone context — session start ($SOURCE); state and pointers only, from runtime/hooks/context.sh]"
if [ "$TEST_MODE" = 1 ]; then
  add "Clone: git state skipped (test fixture)."
else
  B=$(git -C "$ROOT" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  H=$(git -C "$ROOT" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$H" ]; then
    A=$(git -C "$ROOT" --no-optional-locks rev-list --count refs/remotes/origin/main..HEAD 2>/dev/null); [ -n "$A" ] || A="?"
    D=$(git -C "$ROOT" --no-optional-locks status --porcelain -uall 2>/dev/null | wc -l | tr -d ' ')
    add "Clone: $B at $H; $A commit(s) not in the local copy of GitHub main (no network check, may be stale); $D uncommitted file(s)."
  else
    add "Clone: git state unavailable."
  fi
fi

# ---------------------------------------------------------------- folder → project notes
SLUGS=""; MATCHED=""; CONTAINED=""
if [ -n "$CWD" ] && [ -d "$PROJ" ]; then
  for f in "$PROJ"/*.md; do
    [ -f "$f" ] || continue
    slug=$(header_field "$f" name); [ -n "$slug" ] || slug=$(basename "$f" .md)
    pv=$(header_field "$f" paths); pv=${pv#\[}; pv=${pv%\]}
    hit=0; inside=0
    while IFS= read -r p; do
      p=$(printf '%s' "$p" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//')
      ap=$(expand_home "$p"); ap=${ap%/}
      [ -n "$ap" ] || continue
      case "$CWD/" in "$ap/"*) hit=1 ;; esac
      case "$ap/" in "$CWD/"?*) inside=1 ;; esac
    done <<EOF
$(printf '%s' "$pv" | tr ',' '\n')
EOF
    if [ "$hit" = 1 ]; then MATCHED="$MATCHED$f$NL"; SLUGS="$SLUGS$slug$NL"
    elif [ "$inside" = 1 ]; then CONTAINED="$CONTAINED$slug$NL"; fi
  done
fi
IN_CLONE=0
if [ -n "$CWD" ]; then case "$CWD/" in "$ROOT/"*) IN_CLONE=1 ;; esac; fi

if [ -z "$CWD" ]; then
  add "Folder: unknown (no usable cwd in hook input)."
elif [ "$IN_CLONE" = 1 ]; then
  add "Folder: $(show_path "$CWD") is the Clone itself (task project \"clone\")."
  SLUGS="clone$NL"
elif [ -n "$MATCHED" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    c=$(header_field "$f" confirmed); c=${c%% *}
    lv=$(header_field "$f" last_verified)
    flag=""
    [ "$c" = soron ] || flag=" — inferred: re-check before acting"
    if [ -n "$lv" ]; then
      e=$(date -j -f '%Y-%m-%d %H:%M:%S' "$lv 12:00:00" +%s 2>/dev/null)
      if [ -n "$e" ]; then
        days=$(( (TODAY - e) / 86400 ))
        if [ "$days" -gt "$STALE_DAYS" ]; then flag="$flag — last verified $days days ago"; fi
      fi
    fi
    add "Folder: $(show_path "$CWD") → project note memory/projects/$(basename "$f") (confirmed: ${c:-?}, last verified: ${lv:-?})$flag"
  done <<EOF
$MATCHED
EOF
elif [ -n "$CONTAINED" ]; then
  add "Folder: $(show_path "$CWD") contains Clone projects: $(join_ids "$CONTAINED") (notes in memory/projects/)."
else
  add "Folder: $(show_path "$CWD"): no Clone project note matches."
fi

# ---------------------------------------------------------------- tasks
if [ ! -f "$TASKS" ]; then
  add "Tasks: tasks/tasks.md not found."
else
  TL=$(awk -F' [|] ' '/^- T-[0-9]+ [|] / { id = $1; sub(/^- /, "", id); print id "\t" $2 "\t" $3 "\t" $4 }' "$TASKS" 2>/dev/null)
  OPEN=0; WAIT=""; BLK=""
  while IFS=$'\t' read -r id st pr ti; do
    [ -n "$id" ] || continue
    case "$st" in COMPLETED|CANCELLED) continue ;; esac
    OPEN=$((OPEN + 1))
    case "$st" in WAITING_FOR_SORON) WAIT="$WAIT$id$NL" ;; BLOCKED) BLK="$BLK$id$NL" ;; esac
  done <<EOF
$TL
EOF
  add "Open tasks: $OPEN (WAITING_FOR_SORON: $(join_ids "$WAIT"); BLOCKED: $(join_ids "$BLK"))."
  if [ -n "$SLUGS" ]; then
    n=0; more=0; lines=""
    while IFS=$'\t' read -r id st pr ti; do
      [ -n "$id" ] || continue
      case "$st" in COMPLETED|CANCELLED) continue ;; esac
      case "$NL$SLUGS" in *"$NL$pr$NL"*) ;; *) continue ;; esac
      n=$((n + 1))
      if [ "$n" -le "$MAX_TASKS" ]; then lines="$lines  $id | $st | $(short "$ti")$NL"; else more=$((more + 1)); fi
    done <<EOF
$TL
EOF
    if [ "$n" -eq 0 ]; then
      add "Open tasks for this project: none."
    else
      add "Open tasks for this project:"
      OUT="$OUT$lines"
      if [ "$more" -gt 0 ]; then add "  … and $more more (see tasks/tasks.md)"; fi
    fi
  fi
fi

# ---------------------------------------------------------------- approvals and pointers
if [ ! -f "$APPROVALS" ]; then
  add "Approvals: tasks/approvals.md not found."
else
  P=$(awk -F' [|] ' '/^- A-[0-9]+ [|] / { id = $1; sub(/^- /, "", id); if ($2 == "requested" || $2 == "approved") print id }' "$APPROVALS" 2>/dev/null)
  add "Pending approvals (requested/approved, not executed): $(join_ids "$P")."
fi
add "Read before acting: runtime/PROTOCOL.md; memory/SCHEMA.md before writing memory; tasks/tasks.md before task work. A permission prompt is never Soron's approval."

# ---------------------------------------------------------------- caps and output
N=$(printf '%s' "$OUT" | awk 'END { print NR }')
if [ "$N" -gt "$MAX_LINES" ]; then OUT="$(printf '%s' "$OUT" | head -n $((MAX_LINES - 1)))$NL(truncated)$NL"; fi
if [ "${#OUT}" -gt "$MAX_CHARS" ]; then OUT="${OUT:0:$((MAX_CHARS - 13))}$NL(truncated)$NL"; fi
printf '%s' "$OUT"
exit 0
