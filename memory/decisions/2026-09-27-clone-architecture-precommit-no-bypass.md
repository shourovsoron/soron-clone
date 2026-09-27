---
name: 2026-09-27-clone-architecture-precommit-no-bypass
type: decision
description: Clone git repo ~/soron-clone with private GitHub backup and the version-controlled pre-commit scan (unchanged); the --no-verify rule now matches the guard - Claude never bypasses the scan, only Soron can, by committing himself or by an approved guard-policy change.
updated: 2026-09-27
confirmed: soron
sources: [Soron's approvals 2026-09-27 (T-0011, option A)]
status: active
supersedes: 2026-09-27-clone-architecture-versioned-precommit
superseded_by: null
decided_by: Soron
---

**Context:** [[2026-09-27-clone-architecture-versioned-precommit]] said "Never bypass it with `--no-verify` without Soron's approval", which implies Claude may bypass the scan once Soron approves. The guard ([[2026-09-26-clone-guard-hook]]) always denies `--no-verify`, `commit -n` and `core.hooksPath`, and a deny is final (`runtime/PROTOCOL.md` §5), so that approval path never existed (Finding 1, T-0011).

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
- **Pre-commit secret scan** is version-controlled at `runtime/git-hooks/pre-commit`; `.git/hooks/pre-commit` is a **symlink** to it, so the committed file is the one that runs.
- **Activation** after a fresh clone: re-create the symlink (`runtime/SETUP.md` §4). Never via `git config core.hooksPath`: the guard denies that, because it is also how the scan could be disabled.
- **Setup guide:** `runtime/SETUP.md` documents the full restore on a new Mac or Claude account, with no secrets.

Changed: who may skip the scan.
- **Claude never uses `--no-verify` or `commit -n`**: the guard always denies them, with or without Soron's approval. If the scan blocks a commit, change the content (a false positive can usually be reworded).
- **Only Soron can skip the scan**, by running that commit himself outside Claude, or through an approved change to the guard policy (CLAUDE.md "Approval model"). This follows the guard's existing pattern for history rewrites ("Soron runs it himself or changes the policy").

**Alternatives considered:**
- Keep the wording and add an approval route to the guard (rejected: the guard only sees Claude's own tool input, so any "approved" signal would be one Claude creates itself; the guard never returns allow).
- Change the guard's deny to ask (rejected: a permission prompt would be the only barrier, and a prompt is never Soron's approval).
- Leave the contradiction (rejected: the rules would keep disagreeing with the enforcement).

**Reason:** the written rule matches what the guard enforces; Soron keeps full authority, and Claude has no route around the secret scan.
