# Task board

Rules: `memory/SCHEMA.md` → Tasks. COMPLETED requires evidence.
States: NEW · PLANNING · IN_PROGRESS · WAITING_FOR_SORON · BLOCKED · VERIFYING · COMPLETED · CANCELLED

`ID | STATE | project | title | next step | updated | blocked_on | needs`

`blocked_on` (what is missing) and `needs` (an approval ID from `tasks/approvals.md`, or one specific question) are required for WAITING_FOR_SORON and BLOCKED tasks and left out otherwise. Approvals: `tasks/approvals.md`.

## Open
- T-0011 | WAITING_FOR_SORON | clone | Finding 1: CLAUDE.md says `--no-verify` is allowed "without Soron's approval" → implies allowed with approval, but the guard always denies `--no-verify` | separate change, deferred by Soron during Phase 4.6; wording kept as is until then | 2026-09-27 | blocked_on: Soron's decision on the fix (align the CLAUDE.md wording with the guard's hard deny, or add an approved-bypass path to the guard) | needs: "How should the `--no-verify` wording vs guard deny be resolved, and when?"
- T-0003 | WAITING_FOR_SORON | clone | Clean up original built-in memory files (`~/.claude/projects/-Users-soron-Desktop-claude-project/memory/`) | keep until Soron approves | 2026-09-26 | blocked_on: Soron's decision whether to delete the three originals (now ported into the Clone) | needs: "Delete the three original built-in memory files and their MEMORY.md, yes or no?"
- T-0005 | IN_PROGRESS | clone | Phase 3 (tool layer) | only the tool-inventory step is approved; next item needs Soron's go-ahead | 2026-09-26

## Standing constraints (from Soron)
Moved to `CLAUDE.md` → "Standing constraints (from Soron)" on 2026-09-27, so they stay loaded in every session.

## Completed
- T-0010 | COMPLETED | clone | Phase 4: Clone runtime (human escalation) | evidence: all steps approved by Soron and done in the approved order 0 → 4.4 → 4.1 → 4.5 → 4.6 → 4.7 → final (A-0001 to A-0040). Commits, all pushed as plain fast-forwards: 07ed5d0 (Step 0: guard + tests), 95bf524 (4.4 approval log + blocked fields), b819b9f (4.1 PROTOCOL.md), 2cedc31 (4.5 context.sh + tests), 01e5c92 (4.6 SessionStart + slim imports), c2974e7 (4.7 SETUP.md + versioned pre-commit hook), 9efd129 (final records, A-0039; pushed A-0040); GitHub main = 9efd129 (`git ls-remote`, 2026-09-27). Verified: guard 70/70 with 0 allow, live deny and ask checked (4.3); context 23/23, live new-session check passed (4.6d); pre-commit hook through the symlink exit 0, positive control 9/9 + 6/6 (4.7d, re-run after A-0034); SETUP.md JSON = live settings.json. Deferred by Soron: Finding 1 → T-0011. Known limit: hard-coded paths (SETUP.md §10) | 2026-09-27
- T-0009 | COMPLETED | clone | Record the GitHub backup in Clone docs | evidence: commit c56eba9 (7 files) pushed as a fast-forward; `git ls-remote` showed GitHub main = c56eba950791349530289b7884b94d8f49397c23; approved by Soron 2026-09-26 | 2026-09-26
- T-0004 | COMPLETED | clone | Phase 3C: private GitHub backup of `~/soron-clone` | evidence: `git push origin main` succeeded (new branch, no force); `git ls-remote origin` shows refs/heads/main = 23eb9fa40955044c412ff182ace6914dc583280f; origin = https://github.com/shourovsoron/soron-clone.git (private repo created by Soron); global config unchanged | 2026-09-26
- T-0008 | COMPLETED | clone | Phase 3B Master Prompt approval-model consistency update | evidence: CLAUDE.md "Approval model" section plus tightened §2/§3/§9/§10/§11/§13/§17/§20, tools.md §7 corrected, decision 2026-09-26-approval-model active; contradiction search clean; approved by Soron 2026-09-26 including all three judgment calls | 2026-09-26
- T-0006 | COMPLETED | clone | Phase 3.1 tool inventory | evidence: `memory/knowledge/tools.md` written; approved by Soron as documentation 2026-09-26 | 2026-09-26
- T-0007 | COMPLETED | clone | Permission allowlist cleanup | evidence: active `settings.local.json` is valid JSON and exactly matches the reviewed 12 allow + 9 ask lists (checked with jq, SHA-256 prefix 3223bc97498754d7); all 38 original rules accounted for; backup `.bak-2026-09-26` deleted on Soron's instruction; final state reviewed and approved by Soron. Minor process violation: a stray `python3 -V` ran during record-keeping (no effect; acknowledged by Soron, not a security incident) | 2026-09-26
- T-0002 | COMPLETED | clone | Phase 2 memory seeding | evidence: notes written and leak-scanned, project repos verified unchanged (same HEAD and change counts); reviewed and approved by Soron 2026-09-26 | 2026-09-26
- T-0001 | COMPLETED | clone | Phase 1 foundation | evidence: a fresh headless `claude -p` session loaded the Clone, identified Soron and read memory (2026-09-26); approved by Soron | 2026-09-26
