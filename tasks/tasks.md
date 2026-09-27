# Task board

Rules: `memory/SCHEMA.md` → Tasks. COMPLETED requires evidence.
States: NEW · PLANNING · IN_PROGRESS · WAITING_FOR_SORON · BLOCKED · VERIFYING · COMPLETED · CANCELLED

`ID | STATE | project | title | next step | updated | blocked_on | needs`

`blocked_on` (what is missing) and `needs` (an approval ID from `tasks/approvals.md`, or one specific question) are required for WAITING_FOR_SORON and BLOCKED tasks and left out otherwise. Approvals: `tasks/approvals.md`.

## Open
- T-0010 | IN_PROGRESS | clone | Phase 4: Clone runtime | done: architecture approved, docs research, global `Bash(git push *)` ask rule, 4.2 guard + 70 offline tests, 4.3 registration + live verification (deny blocked; ask prompted and Soron approved), Step 0 commit 07ed5d0 pushed (A-0001, A-0002), 4.4 approvals log + blocked fields + SCHEMA.md (A-0003, A-0004; committed 95bf524, pushed A-0006), 4.1 PROTOCOL.md + CLAUDE.md pointers + SCHEMA timing exception (A-0014 to A-0017; committed b819b9f A-0018, pushed A-0019), 4.5 SessionStart context script built and tested offline (A-0020 to A-0023: SCHEMA `paths:` rule + 6 project-note headers; context.sh + run-context.sh + 23 cases + 9 fixtures; context suite 23/23, guard suite 70/70; committed 2cedc31 A-0024, pushed A-0025), 4.6 SessionStart hook registered (A-0026) + imports slimmed to INDEX.md + standing constraints moved into CLAUDE.md + PROTOCOL.md §1 (A-0027), verified: context 23/23, guard 70/70, live new-session check passed (A-0028), records (A-0029); committed 01e5c92 A-0030, pushed A-0031, 4.7 `runtime/SETUP.md` + pre-commit hook version-controlled at `runtime/git-hooks/pre-commit` (A-0032), `.git/hooks/pre-commit` → symlink (A-0033), stale header comment fixed, comment-only, sha256 a48cb48b… (A-0034), verification passed (hook exit 0, 9/9 + 6/6 through the link, guard 70/70, context 23/23), CLAUDE.md + decision 2026-09-27-clone-architecture-versioned-precommit (supersedes 2026-09-26-clone-architecture-github-backup) + INDEX + records (A-0035). Deferred by Soron: Finding 1 (`--no-verify` wording in CLAUDE.md vs guard) as a separate later change. Not done: 4.7f commit, 4.7g push, final. Order approved: 0 → 4.4 → 4.1 → 4.5 → 4.6 → 4.7 → final | 2026-09-27
- T-0003 | WAITING_FOR_SORON | clone | Clean up original built-in memory files (`~/.claude/projects/-Users-soron-Desktop-claude-project/memory/`) | keep until Soron approves | 2026-09-26 | blocked_on: Soron's decision whether to delete the three originals (now ported into the Clone) | needs: "Delete the three original built-in memory files and their MEMORY.md, yes or no?"
- T-0005 | IN_PROGRESS | clone | Phase 3 (tool layer) | only the tool-inventory step is approved; next item needs Soron's go-ahead | 2026-09-26

## Standing constraints (from Soron)
Moved to `CLAUDE.md` → "Standing constraints (from Soron)" on 2026-09-27, so they stay loaded in every session.

## Completed
- T-0009 | COMPLETED | clone | Record the GitHub backup in Clone docs | evidence: commit c56eba9 (7 files) pushed as a fast-forward; `git ls-remote` showed GitHub main = c56eba950791349530289b7884b94d8f49397c23; approved by Soron 2026-09-26 | 2026-09-26
- T-0004 | COMPLETED | clone | Phase 3C: private GitHub backup of `~/soron-clone` | evidence: `git push origin main` succeeded (new branch, no force); `git ls-remote origin` shows refs/heads/main = 23eb9fa40955044c412ff182ace6914dc583280f; origin = https://github.com/shourovsoron/soron-clone.git (private repo created by Soron); global config unchanged | 2026-09-26
- T-0008 | COMPLETED | clone | Phase 3B Master Prompt approval-model consistency update | evidence: CLAUDE.md "Approval model" section plus tightened §2/§3/§9/§10/§11/§13/§17/§20, tools.md §7 corrected, decision 2026-09-26-approval-model active; contradiction search clean; approved by Soron 2026-09-26 including all three judgment calls | 2026-09-26
- T-0006 | COMPLETED | clone | Phase 3.1 tool inventory | evidence: `memory/knowledge/tools.md` written; approved by Soron as documentation 2026-09-26 | 2026-09-26
- T-0007 | COMPLETED | clone | Permission allowlist cleanup | evidence: active `settings.local.json` is valid JSON and exactly matches the reviewed 12 allow + 9 ask lists (checked with jq, SHA-256 prefix 3223bc97498754d7); all 38 original rules accounted for; backup `.bak-2026-09-26` deleted on Soron's instruction; final state reviewed and approved by Soron. Minor process violation: a stray `python3 -V` ran during record-keeping (no effect; acknowledged by Soron, not a security incident) | 2026-09-26
- T-0002 | COMPLETED | clone | Phase 2 memory seeding | evidence: notes written and leak-scanned, project repos verified unchanged (same HEAD and change counts); reviewed and approved by Soron 2026-09-26 | 2026-09-26
- T-0001 | COMPLETED | clone | Phase 1 foundation | evidence: a fresh headless `claude -p` session loaded the Clone, identified Soron and read memory (2026-09-26); approved by Soron | 2026-09-26
