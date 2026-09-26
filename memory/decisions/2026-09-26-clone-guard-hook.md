---
name: 2026-09-26-clone-guard-hook
type: decision
description: The Clone's approval model gets a harness-level backstop — a global PreToolUse hook (runtime/hooks/guard.sh) that only ever returns nothing, ask or deny, plus a global native ask rule for git push.
updated: 2026-09-26
confirmed: soron
sources:
  - Soron's approvals 2026-09-26 (Phase 4 architecture, docs research, git-push ask rule, 4.2 guard, 4.3 registration and live verification)
  - Claude Code docs (code.claude.com: permissions, permission-modes, hooks guide), read 2026-09-26
status: active
supersedes: null
superseded_by: null
decided_by: Soron
---

**Context:** the approval model lived only in instructions. Claude Code enforces permission rules and hooks, "not the model"; auto mode pushes to the current repository without a prompt unless an ask rule matches.

**Decision:**
- **Layer 0 (primary): conversation approval.** Unchanged. A Claude Code prompt, including one forced by the guard, is **not** Soron's approval.
- **Layer A: native permission rules.** Global `permissions.ask`: `Bash(git push *)`.
- **Layer B: the guard.** `runtime/hooks/guard.sh` with `runtime/policy.json` (the enforcement subset of `tools.md`), registered globally as a `PreToolUse` hook (matcher `"*"`, timeout 10 s).
  - **Never returns allow.**
  - **none:** read-only work, Clone records, scratchpad.
  - **ask:** project, config and Clone-runtime writes; git writes; MCP and external writes; shell or interpreter wrappers; package, process and remote commands; transcript and photos-audit reads.
  - **deny:** secret files; `--no-verify`, `commit -n`, `core.hooksPath` bypass; force-push and history rewrites; `sudo`, `su`, `security`.
  - **fail closed** (exit 2): bad input, missing `jq` or policy, internal errors.
- **Tests:** 70 offline cases in `runtime/tests/` (run `runtime/tests/run.sh`).

**Verified live 2026-09-26:** registered mid-session, active immediately. Deny blocked a Read and a Bash call on a nonexistent `.env`-pattern path. Real Read, Write, Edit, Bash and MCP inputs were parsed. **Ask showed a prompt in auto mode, which Soron saw and approved** (`bash -c 'true'`).

**Known limits:**
- Not a sandbox: variable indirection (`x=git; $x push`) and runtime-built commands get past it.
- "ask" in bypass or `-p` mode is unverified.
- Some false positives (any mention of `.env`; `-n` or `--amend` in `-m` text).

**Alternatives considered:**
- Instructions only (rejected: nothing enforced).
- A hook that can "allow" (rejected: it could only loosen, never tighten).
- A `PermissionRequest` auto-approver (rejected: it would approve prompts).
- Full sandboxing (postponed).

**Rollback:** remove the `hooks` entry from `~/.claude/settings.json`, or set `"disableAllHooks": true`.
