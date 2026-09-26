#!/bin/bash
# Offline test runner for runtime/hooks/guard.sh. Feeds each case in cases.jsonl to the
# guard on stdin and compares the decision with the expected one. It does not register
# hooks, call Claude Code, touch the network or write any file.
set -u
DIR=$(cd "$(dirname "$0")" && pwd -P)
GUARD="$DIR/../hooks/guard.sh"
CASES="$DIR/cases.jsonl"
JQ=/usr/bin/jq
DEFAULTS='{"hook_event_name":"PreToolUse","session_id":"offline-test","transcript_path":"/nonexistent/offline-test.jsonl","cwd":"/Users/soron/Desktop/claude-project","scratchpad_dir":"/private/tmp/claude-501/-Users-soron-Desktop-claude-project/69998208-a4da-4ede-b6d9-5feb3c62b028/scratchpad","permission_mode":"default"}'

pass=0; fail=0; allow=0
while IFS= read -r line; do
  case "$line" in ''|\#*) continue ;; esac
  id=$(printf '%s' "$line" | "$JQ" -r '.id')
  exp=$(printf '%s' "$line" | "$JQ" -r '.expect')
  desc=$(printf '%s' "$line" | "$JQ" -r '.desc')
  if printf '%s' "$line" | "$JQ" -e 'has("raw")' >/dev/null; then
    input=$(printf '%s' "$line" | "$JQ" -j '.raw')
  else
    input=$(printf '%s' "$line" | "$JQ" -c --argjson d "$DEFAULTS" '$d + .input')
  fi
  res=$( { printf '%s' "$input" | "$GUARD"; echo "EXIT:$?"; } 2>&1 )
  code=${res##*EXIT:}
  body=${res%EXIT:*}
  if [ "$code" = 2 ]; then
    case "$body" in *FAIL-CLOSED*) got=failclosed ;; *": DENY:"*) got=deny ;; *) got=block-unlabelled ;; esac
  elif [ "$code" = 0 ]; then
    case "$body" in
      *'"allow"'*) got=ALLOW; allow=$((allow + 1)) ;;
      *'"permissionDecision":"ask"'*) got=ask ;;
      '') got=none ;;
      *) got=unexpected-output ;;
    esac
  else
    got="exit-$code"
  fi
  if [ "$got" = "$exp" ]; then pass=$((pass + 1)); st=PASS; else fail=$((fail + 1)); st=FAIL; fi
  printf '%s %-4s expect=%-10s got=%-10s %s\n' "$id" "$st" "$exp" "$got" "$desc"
  if [ "$got" != none ]; then
    reason=$(printf '%s' "$body" | head -1 | sed -e 's/.*permissionDecisionReason":"//' -e 's/"}}$//' -e 's/^Soron Clone guard: //')
    printf '         -> %s\n' "$reason"
  fi
done < "$CASES"
echo "total=$((pass + fail)) pass=$pass fail=$fail allow_decisions=$allow"
[ "$fail" -eq 0 ] && [ "$allow" -eq 0 ]
