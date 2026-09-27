#!/bin/bash
# Offline test runner for runtime/hooks/context.sh. Feeds each case in context-cases.jsonl
# to the script and checks: exit code 0, expected text present/absent, line and size caps,
# and that no secret-shaped value appears in the output. It registers no hooks, uses no
# network and writes no files.
set -u
DIR=$(cd "$(dirname "$0")" && pwd -P)
CLONE=$(cd "$DIR/../.." && pwd -P)
CTX="$CLONE/runtime/hooks/context.sh"
CASES="$DIR/context-cases.jsonl"
JQ=/usr/bin/jq
GREP=/usr/bin/grep
HOOK="$CLONE/.git/hooks/pre-commit"

# Secret-pattern check reuses the pre-commit hook's own pattern (with a positive control).
VALUE_RE=""
if [ -r "$HOOK" ]; then
  VALUE_RE=$(sed -n "s/^VALUE_RE='\(.*\)'\$/\1/p" "$HOOK"); q="'"; VALUE_RE=${VALUE_RE//\'\"\'\"\'/$q}
fi
pc=0
if [ -n "$VALUE_RE" ]; then
  A=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  for s in "ghp_$A" "sk-$A" "AKIA$(printf ABCDEFGHIJKLMNOP)" "API_KEY=$(printf abcd1234efgh5678)"; do
    printf '%s\n' "$s" | $GREP -Eiq "$VALUE_RE" && pc=$((pc + 1))
  done
  echo "secret-pattern positive control: $pc/4"
else
  echo "secret-pattern check SKIPPED: $HOOK not readable"
fi

sub() { local s="$1"; s=${s//\{HOME\}/$HOME}; s=${s//\{CLONE\}/$CLONE}; s=${s//\{FIX\}/$FIXDIR}; printf '%s' "$s"; }

pass=0; fail=0; start=$SECONDS
while IFS= read -r line; do
  case "$line" in ''|\#*) continue ;; esac
  id=$(printf '%s' "$line" | $JQ -r '.id')
  desc=$(printf '%s' "$line" | $JQ -r '.desc')
  root=$(printf '%s' "$line" | $JQ -r '.root // "real"')
  FIXDIR=""; [ "$root" = real ] || FIXDIR="$DIR/fixtures/$root"
  ENVV=()
  [ -n "$FIXDIR" ] && ENVV+=("CLONE_CONTEXT_ROOT=$FIXDIR")
  ov=$(printf '%s' "$line" | $JQ -r '.override_root // empty'); [ -n "$ov" ] && ENVV+=("CLONE_CONTEXT_ROOT=$ov")
  td=$(printf '%s' "$line" | $JQ -r '.today // empty'); [ -n "$td" ] && ENVV+=("CLONE_CONTEXT_TODAY=$td")
  [ "$(printf '%s' "$line" | $JQ -r '.no_jq // false')" = true ] && ENVV+=("CLONE_CONTEXT_NO_JQ=1")
  if printf '%s' "$line" | $JQ -e 'has("raw")' >/dev/null; then
    input=$(printf '%s' "$line" | $JQ -j '.raw')
  else
    input=$(sub "$(printf '%s' "$line" | $JQ -c '.input')")
  fi
  out=$(printf '%s' "$input" | env ${ENVV[@]+"${ENVV[@]}"} "$CTX" 2>/dev/null); code=$?

  ok=1; why=""
  [ "$code" = 0 ] || { ok=0; why="$why exit=$code;"; }
  while IFS= read -r s; do
    [ -n "$s" ] || continue; s=$(sub "$s")
    case "$out" in *"$s"*) ;; *) ok=0; why="$why missing[$s];" ;; esac
  done <<< "$(printf '%s' "$line" | $JQ -r '.expect_contains // [] | .[]')"
  while IFS= read -r s; do
    [ -n "$s" ] || continue; s=$(sub "$s")
    case "$out" in *"$s"*) ok=0; why="$why unexpected[$s];" ;; esac
  done <<< "$(printf '%s' "$line" | $JQ -r '.expect_not_contains // [] | .[]')"
  if [ "$(printf '%s' "$line" | $JQ -r '.expect_empty // false')" = true ] && [ -n "$out" ]; then ok=0; why="$why not-empty;"; fi
  ml=$(printf '%s' "$line" | $JQ -r '.max_lines // 25')
  nl=0; [ -n "$out" ] && nl=$(printf '%s\n' "$out" | awk 'END { print NR }')
  [ "$nl" -le "$ml" ] || { ok=0; why="$why lines=$nl>$ml;"; }
  bytes=$(printf '%s' "$out" | LC_ALL=C wc -c | tr -d ' ')
  [ "$bytes" -le 2300 ] || { ok=0; why="$why bytes=$bytes;"; }
  if [ -n "$VALUE_RE" ] && printf '%s\n' "$out" | $GREP -Eiq "$VALUE_RE"; then ok=0; why="$why secret-shaped-output;"; fi

  if [ "$ok" = 1 ]; then pass=$((pass + 1)); st=PASS; else fail=$((fail + 1)); st=FAIL; fi
  printf '%s %-4s %s (%s lines, %s bytes)%s\n' "$id" "$st" "$desc" "$nl" "$bytes" "${why:+  ->$why}"
done < "$CASES"
echo "total=$((pass + fail)) pass=$pass fail=$fail elapsed=$((SECONDS - start))s"
[ "$fail" -eq 0 ]
