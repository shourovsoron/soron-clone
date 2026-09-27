---
name: 2026-09-26-clone-architecture-github-backup
type: decision
description: Clone memory lives in the git repo ~/soron-clone, authoritative over Claude built-in memory, following memory/SCHEMA.md — now backed up to Soron's private GitHub repo shourovsoron/soron-clone.
updated: 2026-09-26
confirmed: soron
sources: [Soron's approvals 2026-09-26 (Phase 3C steps 1–7 and follow-ups)]
status: superseded
supersedes: 2026-09-26-clone-memory-architecture
superseded_by: 2026-09-27-clone-architecture-versioned-precommit
decided_by: Soron
---

**Context:** [[2026-09-26-clone-memory-architecture]] made the Clone local-only, with a private remote backup as a later approved step. That step was completed on 2026-09-26 (Phase 3C, T-0004).

**Decision.** Restated unchanged from the superseded decision:
- The Clone is the git repository `~/soron-clone`, loaded globally through `~/.claude/CLAUDE.md`.
- `memory/` is the authoritative long-term memory. Claude's built-in memory may exist but is not authoritative.
- Schema: `memory/SCHEMA.md`. Keep current, inferred and historical information separate; decision records are immutable; COMPLETED needs evidence.

Changed: git and backup.
- **Remote:** `origin` = `https://github.com/shourovsoron/soron-clone.git`, a **private** repository in Soron's own GitHub account, created by Soron. First pushed 2026-09-26: `main` = `23eb9fa`.
- **Commit identity:** repo-local only ("Shourov Hossain Soron" with the GitHub noreply address). Global git config is never changed.
- **Local pre-commit secret scan** in `.git/hooks/pre-commit`. It isn't version-controlled, so re-create it after a fresh clone. Never bypass it with `--no-verify` without Soron's approval.
- **Approvals** (CLAUDE.md "Approval model", rule 2):
  - every commit needs Soron's approval;
  - every push is DESTRUCTIVE_APPROVAL_REQUIRED, approved immediately before;
  - no force-push or history rewrite;
  - changing the remote, repository visibility or GitHub settings needs approval.
- **Backup scope:** GitHub holds only what has been committed **and** pushed. Uncommitted or unpushed changes exist only on this Mac.

**Alternatives considered:** stay local-only (rejected: one disk failure loses the Clone); install `gh` and create the repo by CLI (rejected by Soron: he created the repo himself, so there's no extra install and no credentials handled by Claude).

**Reason:** an off-machine, account-independent backup that Soron controls, with full history.
