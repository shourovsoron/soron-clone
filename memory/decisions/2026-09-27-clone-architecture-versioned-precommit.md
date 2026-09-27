---
name: 2026-09-27-clone-architecture-versioned-precommit
type: decision
description: Clone git repo ~/soron-clone with private GitHub backup (unchanged), now with the pre-commit secret scan version-controlled at runtime/git-hooks/pre-commit and symlinked from .git/hooks; setup documented in runtime/SETUP.md.
updated: 2026-09-27
confirmed: soron
sources: [Soron's approvals 2026-09-27 (Phase 4.7, A-0032 to A-0035)]
status: superseded
supersedes: 2026-09-26-clone-architecture-github-backup
superseded_by: 2026-09-27-clone-architecture-precommit-no-bypass
decided_by: Soron
---

**Context:** [[2026-09-26-clone-architecture-github-backup]] kept the pre-commit secret scan only in `.git/hooks/pre-commit`, which is not version-controlled, so a fresh clone had no scan until someone re-created it by hand. Phase 4.7 fixes that.

**Decision.** Restated unchanged from the superseded decision:
- The Clone is the git repository `~/soron-clone`, loaded globally through `~/.claude/CLAUDE.md`.
- `memory/` is the authoritative long-term memory. Claude's built-in memory may exist but is not authoritative.
- Schema: `memory/SCHEMA.md`. Keep current, inferred and historical information separate; decision records are immutable; COMPLETED needs evidence.
- **Remote:** `origin` = `https://github.com/shourovsoron/soron-clone.git`, a **private** repository in Soron's own GitHub account, created by Soron. First pushed 2026-09-26: `main` = `23eb9fa`.
- **Commit identity:** repo-local only ("Shourov Hossain Soron" with the GitHub noreply address). Global git config is never changed.
- **Approvals** (CLAUDE.md "Approval model", rule 2):
  - every commit needs Soron's approval;
  - every push is DESTRUCTIVE_APPROVAL_REQUIRED, approved immediately before;
  - no force-push or history rewrite;
  - changing the remote, repository visibility or GitHub settings needs approval.
- **Backup scope:** GitHub holds only what has been committed **and** pushed. Uncommitted or unpushed changes exist only on this Mac.

Changed: the pre-commit hook.
- **Pre-commit secret scan** is version-controlled at `runtime/git-hooks/pre-commit`, copied byte for byte from the previous `.git/hooks/pre-commit`; afterwards only its header comment was corrected (A-0034), and the scanning logic is unchanged. `.git/hooks/pre-commit` is a **symlink** to it, so the committed file is the one that runs. Never bypass it with `--no-verify` without Soron's approval. (That wording is kept as is: Finding 1, deferred by Soron.)
- **Activation** after a fresh clone: re-create the symlink (`runtime/SETUP.md` §4). Never via `git config core.hooksPath`: the guard denies that, because it is also how the scan could be disabled.
- **Setup guide:** `runtime/SETUP.md` documents the full restore on a new Mac or Claude account, with no secrets.

**Alternatives considered:**
- Keep the hook unversioned (rejected: a fresh clone has no scan).
- `core.hooksPath` (rejected: the guard denies it by design).
- Copy instead of symlink (rejected: the running hook could drift from the committed one).

**Reason:** the scan that protects every commit is itself committed, reviewed and restorable.
