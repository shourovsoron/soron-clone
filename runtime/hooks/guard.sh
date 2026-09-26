#!/bin/bash
# Soron Digital Clone: PreToolUse guard (Phase 4.2). NOT a sandbox: an extra backstop
# for the approval model in ~/soron-clone/CLAUDE.md. Policy data: runtime/policy.json,
# the enforcement subset of memory/knowledge/tools.md.
#
# Claude Code PreToolUse contract used here:
#   no output, exit 0     -> no decision (normal permission flow applies)
#   JSON "ask", exit 0    -> forces a permission prompt
#   stderr, exit 2        -> blocks the call (DENY, or FAIL-CLOSED)
# This script NEVER returns "allow". It reads only stdin and policy.json:
# no network, no transcripts, no writes.

set -u
set -E
export LC_ALL=C

PREFIX="Soron Clone guard"
JQ=/usr/bin/jq
NL=$'\n'
DONE=0

fail_closed() {
  trap - ERR
  printf '%s: FAIL-CLOSED: %s\n' "$PREFIX" "$1" >&2
  DONE=1
  exit 2
}
# Any failing command -> fail closed. Any exit other than our own 0/2 -> exit 2.
trap 'fail_closed "internal error at line $LINENO"' ERR
trap 'rc=$?; if [ "$DONE" != 1 ] || { [ "$rc" != 0 ] && [ "$rc" != 2 ]; }; then printf "%s: FAIL-CLOSED: unexpected exit (%s)\n" "$PREFIX" "$rc" >&2; exit 2; fi' EXIT

# ---------------------------------------------------------------- setup
[ -x "$JQ" ] || fail_closed "jq not found at $JQ"
SELF_DIR=$(cd "$(dirname "$0")" && pwd -P)
CLONE=$(cd "$SELF_DIR/../.." && pwd -P)
POLICY="$CLONE/runtime/policy.json"
[ -r "$POLICY" ] || fail_closed "policy not readable: $POLICY"
HOME_DIR=${HOME:-}
[ -n "$HOME_DIR" ] || fail_closed "HOME is not set"

if ! "$JQ" -e '.version == 1
    and (.paths | [.secret_basename_regex, .secret_exempt_basename_regex, .secret_path_regex,
                   .claude_config_regex, .transcript_regex, .offlimits_regex] | all(type == "string"))
    and (.bash.npx_safe_regex | type == "string")' "$POLICY" >/dev/null 2>&1; then
  fail_closed "policy.json is invalid or incomplete"
fi

POLICY_SH=$("$JQ" -r '
  def L(x): (x // []) | map(tostring) | join("\n");
  "P_SCRATCH=\(L(.paths.scratch_prefixes) | @sh)",
  "P_RECDIRS=\(L(.paths.clone_record_dirs) | @sh)",
  "P_CFGFILES=\(L(.paths.clone_config_files) | @sh)",
  "P_SECRET_RE=\(.paths.secret_basename_regex | @sh)",
  "P_SECRET_EXEMPT_RE=\(.paths.secret_exempt_basename_regex | @sh)",
  "P_SECRET_PATH_RE=\(.paths.secret_path_regex | @sh)",
  "P_CLAUDECFG_RE=\(.paths.claude_config_regex | @sh)",
  "P_TRANSCRIPT_RE=\(.paths.transcript_regex | @sh)",
  "P_OFFLIMITS_RE=\(.paths.offlimits_regex | @sh)",
  "T_NONE=\(L(.tools.none) | @sh)",
  "T_ASK=\(L(.tools.ask) | @sh)",
  "T_PREAD=\(L(.tools.path_read) | @sh)",
  "T_PWRITE=\(L(.tools.path_write) | @sh)",
  "T_GREP=\(L(.tools.grep) | @sh)",
  "T_ACTION=\(L(.tools.action | keys) | @sh)",
  "M_READ_RE=\(L(.mcp_read_only_regex) | @sh)",
  "B_DENY=\(L(.bash.deny_cmds) | @sh)",
  "B_INTERP=\(L(.bash.interpreters) | @sh)",
  "B_INTERP_SAFE=\(L(.bash.interpreter_safe_args) | @sh)",
  "B_WRAP=\(L(.bash.wrappers) | @sh)",
  "B_ASK=\(L(.bash.ask_cmds) | @sh)",
  "B_FMOD=\(L(.bash.file_modifiers) | @sh)",
  "G_READ=\(L(.bash.git.read) | @sh)",
  "G_DENY=\(L(.bash.git.deny_subcommands) | @sh)",
  "G_BR_FLAGS=\(L(.bash.git.branch_read_flags) | @sh)",
  "G_BR_PREFIX=\(L(.bash.git.branch_read_prefixes) | @sh)",
  "PKG_CMDS=\(L(.bash.pkg | keys) | @sh)",
  "NPX_SAFE_RE=\(.bash.npx_safe_regex | @sh)"
' "$POLICY")
eval "$POLICY_SH"

HOME_RE=$(printf '%s' "$HOME_DIR" | sed 's/[][\.*^$+?(){}|]/\\&/g')
P_CLAUDECFG_RE=${P_CLAUDECFG_RE//\{HOME\}/$HOME_RE}
P_TRANSCRIPT_RE=${P_TRANSCRIPT_RE//\{HOME\}/$HOME_RE}

# ---------------------------------------------------------------- input
INPUT=$(cat)
[ -n "$INPUT" ] || fail_closed "empty input"
if ! printf '%s' "$INPUT" | "$JQ" -e 'type == "object"
      and (.tool_name | type == "string" and length > 0)
      and (.tool_input | type == "object")
      and ((.hook_event_name // "PreToolUse") == "PreToolUse")' >/dev/null 2>&1; then
  fail_closed "malformed JSON, missing tool_name/tool_input, or not a PreToolUse event"
fi
jqi() { printf '%s' "$INPUT" | "$JQ" -r "$@"; }
TOOL=$(jqi '.tool_name')
CWD=$(jqi '.cwd // "" | tostring')
SCRATCH=$(jqi '.scratchpad_dir // "" | tostring')

# ---------------------------------------------------------------- decision state
LEVEL=0    # 0 none, 1 ask, 2 deny
REASON=""
raise() { if [ "$1" -gt "$LEVEL" ]; then LEVEL=$1; REASON=$2; fi; return 0; }

finish() {
  trap - ERR
  if [ "$LEVEL" -ge 2 ]; then
    printf '%s: DENY: %s\n' "$PREFIX" "$REASON" >&2
    DONE=1; exit 2
  fi
  if [ "$LEVEL" -eq 1 ]; then
    local out
    if ! out=$("$JQ" -cn --arg r "$PREFIX: $REASON" \
        '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $r}}'); then
      fail_closed "could not build ask output"
    fi
    printf '%s\n' "$out"
    DONE=1; exit 0
  fi
  DONE=1; exit 0
}

in_list() { case "$NL$2$NL" in *"$NL$1$NL"*) return 0 ;; esac; return 1; }

# ---------------------------------------------------------------- paths
norm_abs() {
  awk -v p="$1" 'BEGIN { n = split(p, a, "/"); k = 0
    for (i = 1; i <= n; i++) { if (a[i] == "" || a[i] == ".") continue
      if (a[i] == "..") { if (k > 0) k--; continue } s[++k] = a[i] }
    o = ""; for (i = 1; i <= k; i++) o = o "/" s[i]; if (o == "") o = "/"; print o }'
}
map_private() {
  case "$1" in
    /tmp|/tmp/*|/var|/var/*|/etc|/etc/*) printf '/private%s' "$1" ;;
    *) printf '%s' "$1" ;;
  esac
}
[ -z "$CWD" ] || CWD=$(map_private "$(norm_abs "$CWD")")
[ -z "$SCRATCH" ] || SCRATCH=$(map_private "$(norm_abs "$SCRATCH")")
CD_SEEN=0

RP=""
resolve() {   # raw path token -> RP (absolute, normalized) or "?" when unknowable
  local p="$1"
  case "$p" in
    "~") p="$HOME_DIR" ;;
    "~/"*) p="$HOME_DIR/${p#\~/}" ;;
  esac
  case "$p" in *'$'*|*'`'*) RP="?"; return 0 ;; esac
  case "$p" in
    /*) ;;
    *) if [ "$CD_SEEN" = 1 ] || [ -z "$CWD" ]; then RP="?"; return 0; fi
       p="$CWD/$p" ;;
  esac
  RP=$(map_private "$(norm_abs "$p")")
  return 0
}

is_secret_name() {
  if [[ $1 =~ $P_SECRET_EXEMPT_RE ]]; then return 1; fi
  if [[ $1 =~ $P_SECRET_RE ]]; then return 0; fi
  return 1
}

PC=""
classify() {  # absolute path or "?" -> PC
  local p="$1" rel d s
  if [ "$p" = "?" ]; then PC=unknown; return 0; fi
  case "$p" in /dev/null|/dev/stdout|/dev/stderr|/dev/fd/*) PC=devnull; return 0 ;; esac
  if is_secret_name "${p##*/}"; then PC=secret; return 0; fi
  if [[ $p =~ $P_SECRET_PATH_RE ]]; then PC=secret; return 0; fi
  if [[ $p =~ $P_TRANSCRIPT_RE ]]; then PC=transcript; return 0; fi
  if [[ $p =~ $P_OFFLIMITS_RE ]]; then PC=offlimits; return 0; fi
  if [[ $p =~ $P_CLAUDECFG_RE ]]; then PC=claude_config; return 0; fi
  case "$p" in
    "$CLONE"|"$CLONE"/*)
      rel=${p#"$CLONE"}; rel=${rel#/}
      if in_list "$rel" "$P_CFGFILES"; then PC=clone_config; return 0; fi
      while IFS= read -r d; do
        if [ -n "$d" ]; then case "$rel" in "$d"*) PC=clone_record; return 0 ;; esac; fi
      done <<< "$P_RECDIRS"
      PC=clone_config; return 0 ;;
  esac
  if [ -n "$SCRATCH" ]; then
    case "$p" in "$SCRATCH"|"$SCRATCH"/*) PC=scratch; return 0 ;; esac
  fi
  while IFS= read -r s; do
    if [ -n "$s" ]; then case "$p" in "$s"*) PC=scratch; return 0 ;; esac; fi
  done <<< "$P_SCRATCH"
  PC=other
  return 0
}

# Level for writing to a path: 0 fine, 1 ask, 2 deny. Sets WHY.
WHY=""
write_level() {
  resolve "$1"; classify "$RP"
  case "$PC" in
    devnull|scratch|clone_record) WHY=""; return 0 ;;
    secret) WHY="write to a secret-bearing file ($1)"; return 2 ;;
    clone_config) WHY="Clone runtime/config self-modification ($1) needs Soron's approval"; return 1 ;;
    claude_config) WHY="Claude Code / git configuration change ($1) needs Soron's approval"; return 1 ;;
    unknown) WHY="write to a path the guard cannot resolve ($1)"; return 1 ;;
    *) WHY="write outside Clone records and scratchpad ($1): project modification needs Soron's approval"; return 1 ;;
  esac
}
check_write_path() {
  local lvl=0
  write_level "$1" || lvl=$?
  if [ "$lvl" -gt 0 ]; then raise "$lvl" "$WHY"; fi
  return 0
}
check_read_path() {
  resolve "$1"; classify "$RP"
  case "$PC" in
    secret) raise 2 "read of a secret-bearing file ($1)" ;;
    transcript) raise 1 "reading a Claude transcript ($1): no transcript scanning without Soron's approval" ;;
    offlimits) raise 1 "photos-audit is off-limits without Soron's approval ($1)" ;;
  esac
  return 0
}

# ---------------------------------------------------------------- tool handlers
handle_write() {
  local fp
  fp=$(jqi '(.tool_input.file_path // .tool_input.notebook_path // empty) | strings')
  [ -n "$fp" ] || fail_closed "$TOOL call without a string file_path"
  check_write_path "$fp"
}

handle_read() {
  local fp
  fp=$(jqi '.tool_input.file_path // empty | strings')
  [ -n "$fp" ] || fail_closed "$TOOL call without a string file_path"
  check_read_path "$fp"
}

handle_grep() {
  local gp gg
  gp=$(jqi '.tool_input.path // "" | tostring')
  gg=$(jqi '.tool_input.glob // "" | tostring')
  if [ -n "$gp" ]; then check_read_path "$gp"; fi
  if [[ $gg =~ (^|[/*{,])\.env ]] && ! [[ $gg =~ \.env\.(example|sample|template|dist)$ ]]; then
    raise 2 "search across secret-bearing files (glob $gg)"
  fi
  return 0
}

handle_action() {
  local field def nonel val
  field=$("$JQ" -r --arg t "$TOOL" '.tools.action[$t].field // empty' "$POLICY")
  def=$("$JQ" -r --arg t "$TOOL" '.tools.action[$t].default // empty' "$POLICY")
  nonel=$("$JQ" -r --arg t "$TOOL" '.tools.action[$t].none // [] | .[]' "$POLICY")
  [ -n "$field" ] || fail_closed "policy action entry for $TOOL has no field"
  val=$(printf '%s' "$INPUT" | "$JQ" -r --arg f "$field" '.tool_input[$f] // empty | tostring')
  [ -n "$val" ] || val="$def"
  if [ -n "$val" ] && in_list "$val" "$nonel"; then return 0; fi
  raise 1 "$TOOL action '${val:-unspecified}' is write-capable or unclassified: needs Soron's approval"
}

handle_mcp() {
  local re
  while IFS= read -r re; do
    if [ -n "$re" ] && [[ $TOOL =~ $re ]]; then return 0; fi
  done <<< "$M_READ_RE"
  raise 1 "MCP / external-system tool $TOOL is write-capable or unclassified: needs Soron's approval"
}

# ---------------------------------------------------------------- Bash
T=(); N=0; A=(); NA=0; R=(); NR=0

check_token() {   # secret / transcript / off-limits references anywhere
  local t="${1##*=}"
  [ -n "$t" ] || return 0
  if is_secret_name "${t##*/}"; then raise 2 "command references a secret-bearing file ($1)"; return 0; fi
  if [[ $t =~ $P_SECRET_PATH_RE ]]; then raise 2 "command references ~/.ssh ($1)"; return 0; fi
  case "$t" in
    */*|'~'*|.*) check_read_path "$t" ;;
  esac
  return 0
}

paths_classify() {   # $1 = command; file-modifying commands
  local c="$1" k t last=""
  case "$c" in
    cp|rsync|ditto|install|ln)
      for ((k = 0; k < NA; k++)); do
        t=${A[$k]}; [ -n "$t" ] || continue
        case "$t" in -*) continue ;; esac
        last=$t
      done
      if [ -n "$last" ]; then check_write_path "$last"; fi
      return 0 ;;
    dd)
      for ((k = 0; k < NA; k++)); do
        t=${A[$k]}
        case "$t" in of=*) check_write_path "${t#of=}" ;; esac
      done
      return 0 ;;
  esac
  for ((k = 0; k < NA; k++)); do
    t=${A[$k]}; [ -n "$t" ] || continue
    case "$t" in -*) continue ;; esac
    check_write_path "$t"
  done
  return 0
}

sed_classify() {
  local k t inplace=0 first=1
  for ((k = 0; k < NA; k++)); do
    case "${A[$k]}" in -i*|--in-place|--in-place=*) inplace=1 ;; esac
  done
  [ "$inplace" = 1 ] || return 0
  for ((k = 0; k < NA; k++)); do
    t=${A[$k]}; [ -n "$t" ] || continue
    case "$t" in -*) continue ;; esac
    if [ "$first" = 1 ]; then first=0; continue; fi
    check_write_path "$t"
  done
  return 0
}

find_classify() {
  local k
  for ((k = 0; k < NA; k++)); do
    case "${A[$k]}" in
      -delete|-exec|-execdir|-ok|-okdir|-fprint|-fprint0|-fprintf|-fls)
        raise 1 "find with ${A[$k]} can modify files or run commands: needs Soron's approval"; return 0 ;;
    esac
  done
  return 0
}

curl_classify() {
  local k t v up
  for ((k = 0; k < NA; k++)); do
    t=${A[$k]}; v=""
    case "$t" in
      -X|--request) v=${A[$((k + 1))]:-} ;;
      --request=*) v=${t#--request=} ;;
      -X*) v=${t#-X} ;;
    esac
    if [ -n "$v" ]; then
      up=$(printf '%s' "$v" | tr '[:lower:]' '[:upper:]')
      if [ "$up" != GET ] && [ "$up" != HEAD ]; then raise 1 "curl $up request writes to an external system: needs Soron's approval"; fi
      continue
    fi
    case "$t" in
      -d|-d*|--data|--data=*|--data-*|--json|--json=*|-F|-F*|--form|--form=*|--form-string|-T|-T*|--upload-file|--upload-file=*)
        raise 1 "curl sends data or uploads to an external system: needs Soron's approval" ;;
      -o|--output) check_write_path "${A[$((k + 1))]:-?}" ;;
      -o*) check_write_path "${t#-o}" ;;
      --output=*) check_write_path "${t#--output=}" ;;
      -O|--remote-name|--remote-name-all|-J|--remote-header-name)
        raise 1 "curl saves a downloaded file: needs Soron's approval" ;;
      -K|--config|-K*|--config=*) raise 1 "curl reads a config file of options: needs Soron's approval" ;;
    esac
  done
  return 0
}

git_cfg_classify() {
  local k t pos=0 hooks=0
  for ((k = 0; k < NR; k++)); do
    t=${R[$k]}
    case "$t" in *[Hh][Oo][Oo][Kk][Ss][Pp][Aa][Tt][Hh]*) hooks=1 ;; esac
  done
  for ((k = 0; k < NR; k++)); do
    case "${R[$k]}" in
      --unset|--unset-all|--add|--replace-all|--edit|-e|--rename-section|--remove-section)
        if [ "$hooks" = 1 ]; then raise 2 "changing core.hooksPath would disable the secret-scan hook"; return 0; fi
        raise 1 "git config write needs Soron's approval"; return 0 ;;
      --get|--get-all|--get-regexp|--get-urlmatch|--list|-l) return 0 ;;
    esac
  done
  for ((k = 0; k < NR; k++)); do
    case "${R[$k]}" in -*) ;; *) pos=$((pos + 1)) ;; esac
  done
  if [ "$pos" -le 1 ]; then return 0; fi
  if [ "$hooks" = 1 ]; then raise 2 "changing core.hooksPath would disable the secret-scan hook"; return 0; fi
  raise 1 "git config write needs Soron's approval"
}

git_classify() {
  local k=0 t sub="" nxt
  while [ "$k" -lt "$NA" ]; do
    t=${A[$k]}
    case "$t" in
      -c)
        nxt=${A[$((k + 1))]:-}
        case "$nxt" in *[Hh][Oo][Oo][Kk][Ss][Pp][Aa][Tt][Hh]*)
          raise 2 "git -c core.hooksPath would bypass the secret-scan hook"; return 0 ;; esac
        k=$((k + 2)); continue ;;
      -C|--git-dir|--work-tree|--namespace|--super-prefix|--exec-path) k=$((k + 2)); continue ;;
      -*) k=$((k + 1)); continue ;;
    esac
    sub=$t; k=$((k + 1)); break
  done
  [ -n "$sub" ] || return 0
  R=(); if [ "$k" -lt "$NA" ]; then R=( "${A[@]:$k}" ); fi; NR=${#R[@]}

  for ((k = 0; k < NR; k++)); do
    if [ "${R[$k]}" = "--no-verify" ]; then
      raise 2 "git --no-verify would bypass the Clone's pre-commit secret scan"; return 0
    fi
  done
  if in_list "$sub" "$G_DENY"; then
    raise 2 "git $sub rewrites history: never run through the guard (Soron runs it himself or changes the policy)"; return 0
  fi

  case "$sub" in
    commit)
      for ((k = 0; k < NR; k++)); do
        t=${R[$k]}
        if [ "$t" = "--amend" ]; then raise 2 "git commit --amend rewrites history"; return 0; fi
        if [[ $t =~ ^-[A-Za-z]*n[A-Za-z]*$ ]]; then raise 2 "git commit $t includes -n (short for --no-verify)"; return 0; fi
      done
      raise 1 "git commit needs Soron's explicit approval"; return 0 ;;
    push)
      for ((k = 0; k < NR; k++)); do
        t=${R[$k]}
        case "$t" in
          --force|--force-with-lease|--force-with-lease=*|--force-if-includes|--mirror|+*)
            raise 2 "force-push / remote history overwrite ($t) is never run through the guard"; return 0 ;;
          --*) ;;
          -*) if [[ $t =~ f ]]; then raise 2 "force-push ($t) is never run through the guard"; return 0; fi ;;
        esac
      done
      raise 1 "git push is DESTRUCTIVE: needs Soron's explicit approval immediately before"; return 0 ;;
    reflog)
      if [ "$NR" -gt 0 ]; then
        case "${R[0]}" in expire|delete) raise 2 "git reflog ${R[0]} destroys history"; return 0 ;; esac
      fi
      return 0 ;;
    branch)
      for ((k = 0; k < NR; k++)); do
        t=${R[$k]}
        if in_list "$t" "$G_BR_FLAGS"; then continue; fi
        local ok=0 pfx
        while IFS= read -r pfx; do
          if [ -n "$pfx" ]; then case "$t" in "$pfx"*) ok=1 ;; esac; fi
        done <<< "$G_BR_PREFIX"
        if [ "$ok" = 1 ]; then continue; fi
        raise 1 "git branch change needs Soron's approval"; return 0
      done
      return 0 ;;
    remote)
      if [ "$NR" -eq 0 ]; then return 0; fi
      case "${R[0]}" in -v|--verbose|get-url|show) return 0 ;; esac
      raise 1 "git remote change needs Soron's approval"; return 0 ;;
    tag)
      if [ "$NR" -eq 0 ]; then return 0; fi
      for ((k = 0; k < NR; k++)); do case "${R[$k]}" in -l|--list) return 0 ;; esac; done
      raise 1 "git tag change needs Soron's approval"; return 0 ;;
    config) git_cfg_classify; return 0 ;;
    stash)
      if [ "$NR" -gt 0 ]; then case "${R[0]}" in list|show) return 0 ;; esac; fi
      raise 1 "git stash changes the working tree: needs Soron's approval"; return 0 ;;
    worktree)
      if [ "$NR" -gt 0 ] && [ "${R[0]}" = list ]; then return 0; fi
      raise 1 "git worktree change needs Soron's approval"; return 0 ;;
    submodule)
      if [ "$NR" -eq 0 ] || [ "${R[0]}" = status ]; then return 0; fi
      raise 1 "git submodule change needs Soron's approval"; return 0 ;;
    notes)
      if [ "$NR" -eq 0 ]; then return 0; fi
      case "${R[0]}" in list|show) return 0 ;; esac
      raise 1 "git notes change needs Soron's approval"; return 0 ;;
  esac
  if in_list "$sub" "$G_READ"; then return 0; fi
  raise 1 "git $sub changes repository state (or is unrecognised): needs Soron's approval"
}

pkg_classify() {
  local c="$1" k t sub="" reads j
  if [ "$c" = npx ]; then
    j="${A[*]:-}"
    if [[ $j =~ $NPX_SAFE_RE ]]; then return 0; fi
    raise 1 "npx may download and execute packages: needs Soron's approval"; return 0
  fi
  for ((k = 0; k < NA; k++)); do
    t=${A[$k]}
    case "$t" in -*) continue ;; esac
    sub=$t; break
  done
  if [ -z "$sub" ]; then
    for ((k = 0; k < NA; k++)); do
      case "${A[$k]}" in --version|-v|-V|--help|-h) ;; *) raise 1 "'$c ${A[$k]}' is unrecognised: needs Soron's approval"; return 0 ;; esac
    done
    return 0
  fi
  reads=$("$JQ" -r --arg c "$c" '.bash.pkg[$c] // [] | .[]' "$POLICY")
  if in_list "$sub" "$reads"; then
    if [ "$c" = npm ] && [ "$sub" = audit ]; then
      for ((k = 0; k < NA; k++)); do
        if [ "${A[$k]}" = fix ]; then raise 1 "npm audit fix installs/upgrades packages: needs Soron's approval"; return 0; fi
      done
    fi
    return 0
  fi
  raise 1 "'$c $sub' installs, runs or changes packages/containers: needs Soron's approval"
}

process_segment() {
  local IFS=$' \t' i tok c w
  T=( $1 )
  N=${#T[@]}
  [ "$N" -gt 0 ] || return 0
  for ((i = 0; i < N; i++)); do
    tok=${T[$i]}; tok=${tok//\"/}; tok=${tok//\'/}; tok=${tok//\\/}
    T[$i]=$tok
  done

  # 1. secret/transcript references and redirections anywhere in the segment
  for ((i = 0; i < N; i++)); do
    tok=${T[$i]}
    case "$tok" in
      ">"|">>")
        if [ $((i + 1)) -lt "$N" ]; then check_write_path "${T[$((i + 1))]}"
        else raise 1 "redirection without a target"; fi ;;
      "<")
        if [ $((i + 1)) -lt "$N" ]; then check_token "${T[$((i + 1))]}"; fi ;;
      *) check_token "$tok" ;;
    esac
  done

  # 2. find the command word (skip VAR=value and wrappers such as nohup/env/xargs)
  i=0
  while [ "$i" -lt "$N" ]; do
    tok=${T[$i]}
    if [[ $tok =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then i=$((i + 1)); continue; fi
    if in_list "$tok" "$B_WRAP"; then
      w=$tok; i=$((i + 1))
      while [ "$i" -lt "$N" ]; do
        tok=${T[$i]}
        case "$w:$tok" in
          xargs:-I|xargs:-n|xargs:-P|xargs:-L|xargs:-s|xargs:-E|xargs:-d|nice:-n|stdbuf:-i|stdbuf:-o|stdbuf:-e|timeout:-s|timeout:-k)
            i=$((i + 2)); continue ;;
        esac
        case "$tok" in -*) i=$((i + 1)); continue ;; esac
        if [ "$w" = timeout ] && [[ $tok =~ ^[0-9.]+[smhd]?$ ]]; then i=$((i + 1)); continue; fi
        if [ "$w" = env ] && [[ $tok =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then i=$((i + 1)); continue; fi
        break
      done
      continue
    fi
    break
  done
  [ "$i" -lt "$N" ] || return 0
  c=${T[$i]}; c=${c##*/}
  A=(); if [ $((i + 1)) -lt "$N" ]; then A=( "${T[@]:$((i + 1))}" ); fi
  NA=${#A[@]}

  # 3. classify the command
  case "$c" in cd|pushd|popd) CD_SEEN=1; return 0 ;; esac
  if in_list "$c" "$B_DENY"; then
    raise 2 "'$c' (privilege escalation / keychain access) is never run through the guard"; return 0
  fi
  if in_list "$c" "$B_INTERP"; then
    if [ "$NA" -eq 1 ] && in_list "${A[0]}" "$B_INTERP_SAFE"; then return 0; fi
    raise 1 "shell/interpreter wrapper '$c' can run arbitrary code: needs Soron's approval"; return 0
  fi
  case "$c" in
    git) git_classify; return 0 ;;
    curl) curl_classify; return 0 ;;
    sed) sed_classify; return 0 ;;
    find) find_classify; return 0 ;;
  esac
  if in_list "$c" "$PKG_CMDS"; then pkg_classify "$c"; return 0; fi
  if in_list "$c" "$B_ASK"; then
    raise 1 "'$c' acts on processes, the system or remote hosts: needs Soron's approval"; return 0
  fi
  if in_list "$c" "$B_FMOD"; then paths_classify "$c"; return 0; fi
  return 0
}

handle_bash() {
  local cmd s line
  cmd=$(jqi '.tool_input.command // empty | strings')
  [ -n "$cmd" ] || fail_closed "Bash call without a string command"

  # Heredoc bodies are data, not commands (a heredoc fed to an interpreter is still
  # caught, because the interpreter on the opening line is classified).
  s=$(printf '%s\n' "$cmd" | awk '
    inhd { t = $0; sub(/^\t+/, "", t); if (t == tag) inhd = 0; next }
    { print; line = $0
      while (match(line, /<<-?[ \t]*["\047]?[A-Za-z_][A-Za-z0-9_]*["\047]?/)) {
        pre = (RSTART > 1) ? substr(line, RSTART - 1, 1) : ""
        tk = substr(line, RSTART, RLENGTH); line = substr(line, RSTART + RLENGTH)
        if (pre == "<") continue
        gsub(/^<<-?[ \t]*|["\047]/, "", tk); tag = tk; inhd = 1
      } }')
  s=${s//\$\{HOME\}/$HOME_DIR}
  s=${s//\$HOME\//$HOME_DIR/}
  s=$(printf '%s\n' "$s" | sed -E \
      -e 's/&>>/ >> /g' -e 's/&>/ > /g' \
      -e 's/[0-9]*>&[0-9-]*//g' -e 's/<&[0-9-]*//g' \
      -e 's/>>/ @APPEND@ /g' -e 's/>/ > /g' -e 's/@APPEND@/>>/g' -e 's/</ < /g' \
    | tr ';|&()`{}' '\n\n\n\n\n\n\n\n')

  set -f
  while IFS= read -r line; do
    process_segment "$line"
  done <<< "$s"
  set +f
  return 0
}

# ---------------------------------------------------------------- dispatch
if in_list "$TOOL" "$T_ACTION"; then handle_action; finish; fi
case "$TOOL" in mcp__*) handle_mcp; finish ;; esac
if [ "$TOOL" = Bash ]; then handle_bash; finish; fi
if in_list "$TOOL" "$T_PWRITE"; then handle_write; finish; fi
if in_list "$TOOL" "$T_PREAD"; then handle_read; finish; fi
if in_list "$TOOL" "$T_GREP"; then handle_grep; finish; fi
if in_list "$TOOL" "$T_NONE"; then finish; fi
if in_list "$TOOL" "$T_ASK"; then raise 1 "$TOOL needs Soron's approval"; finish; fi
raise 1 "unrecognised tool '$TOOL': asking instead of allowing"
finish
fail_closed "no decision reached"
