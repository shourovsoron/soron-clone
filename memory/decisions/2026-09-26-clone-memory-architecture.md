---
name: 2026-09-26-clone-memory-architecture
type: decision
description: Digital Clone memory lives in a local repo at ~/soron-clone, is authoritative over Claude built-in memory, and follows memory/SCHEMA.md.
updated: 2026-09-26
confirmed: soron
sources: [Soron's approvals, 2026-09-26]
status: superseded
supersedes: null
superseded_by: 2026-09-26-clone-architecture-github-backup
decided_by: Soron
---

**Context:** the Clone must survive changes of Claude account, session and machine. Claude's built-in memory is split by folder and tied to one machine.

**Decision:**
- The Clone is the local repository `~/soron-clone`, loaded globally through `~/.claude/CLAUDE.md`.
- `memory/` is the authoritative long-term memory. Claude's built-in memory may exist but is not authoritative.
- Schema: `memory/SCHEMA.md`. Separate current, inferred and historical information; decision records are immutable; COMPLETED needs evidence.
- Local-only git: no GitHub repo, remote, commit or push without asking. A private remote backup is a later approved step.

**Alternatives considered:** Claude built-in memory only (rejected: tied to one folder and machine); claude.ai project knowledge (rejected: tied to an account).

**Reason:** account independence, one source of truth, reviewable history.
