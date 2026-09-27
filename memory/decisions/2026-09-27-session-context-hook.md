---
name: 2026-09-27-session-context-hook
type: decision
description: runtime/hooks/context.sh is registered as the global SessionStart hook; CLAUDE.md now auto-loads only the memory index (SCHEMA.md and tasks.md on demand); the standing constraints moved into CLAUDE.md.
updated: 2026-09-27
confirmed: soron
sources:
  - Soron's approvals 2026-09-27 (Phase 4.5 design choices Q1–Q4; Phase 4.6 option A and live check (i); A-0020 to A-0029)
  - Claude Code docs (hooks guide: SessionStart stdout is added to context), read 2026-09-26
status: active
supersedes: null
superseded_by: null
decided_by: Soron
---

**Context:** every session on this Mac loaded about 43 KB, including the full schema and task board, in any folder. Nothing connected a folder to its project note. Complements [[2026-09-26-clone-guard-hook]], which covers the PreToolUse backstop.

**Decision:**
- **SessionStart hook:** `~/.claude/settings.json` → `hooks.SessionStart`, matcher `startup|resume|clear|compact`, command `/Users/soron/soron-clone/runtime/hooks/context.sh`, timeout 10.
  - The script is read-only: it only reads its input, project-note headers, `tasks.md`, `approvals.md` and local git state.
  - No network; never reads transcripts, project files or secrets; always exits 0.
  - It prints at most 25 lines of state and pointers: Clone backup state (local tracking ref), the project note matching the folder via `paths:`, open-task counts, WAITING_FOR_SORON/BLOCKED IDs, pending approvals.
  - It grants nothing and is not an approval.
- **Imports slimmed:** `CLAUDE.md` imports only `@memory/INDEX.md`. `memory/SCHEMA.md` is read before writing memory or records, `tasks/tasks.md` before task work, `tasks/approvals.md` before approval-requiring steps (`CLAUDE.md` pointer; `runtime/PROTOCOL.md` §1).
- **Standing constraints (option A):** the 5 constraints moved from `tasks/tasks.md` into `CLAUDE.md` → "Standing constraints (from Soron)"; `tasks.md` keeps a pointer. The two memory "Never" items (raw transcripts, `photos-audit` content) are copied there; `SCHEMA.md` → Never stays the full rule.
- The PreToolUse guard and the `Bash(git push *)` ask rule are unchanged.

**Verification (2026-09-27):**
- context suite 23/23; guard suite 70/70 with 0 allow;
- realistic inputs produce correct blocks (~0.7 KB);
- always-loaded 43,389 → 33,859 bytes;
- Soron's live check in a new session passed.

**Alternatives considered:**
- Keep both imports (rejected: size, and no folder-to-note link).
- Option B, keep `tasks.md` imported (rejected by Soron).
- Option C, slim without moving the constraints (rejected: it would weaken standing constraints).
- A headless `claude -p` live check (not chosen; Soron checked in a new session).

**Known limits:** the summary can be missing (script failure or timeout) or stale (no network; local tracking ref). It's a pointer, never a substitute for reading the files.

**Rollback:**
- remove the `SessionStart` entry from `hooks` in `~/.claude/settings.json` (or `"disableAllHooks": true`, which also disables the guard);
- restore `@memory/SCHEMA.md` and `@tasks/tasks.md` in `CLAUDE.md`.
