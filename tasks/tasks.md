# Task board

Rules: `memory/SCHEMA.md` → Tasks. COMPLETED requires evidence.
States: NEW · PLANNING · IN_PROGRESS · WAITING_FOR_SORON · BLOCKED · VERIFYING · COMPLETED · CANCELLED

`ID | STATE | project | title | next step | updated`

## Open
- T-0003 | WAITING_FOR_SORON | clone | Clean up original built-in memory files (`~/.claude/projects/-Users-soron-Desktop-claude-project/memory/`) | keep until Soron approves | 2026-09-26
- T-0004 | IN_PROGRESS | clone | Phase 3C: private GitHub backup of `~/soron-clone` | steps 1–3 done (safety check; .gitignore + secret-scan hook; repo-local commit identity); next: step 4 first commit, waits for Soron | 2026-09-26
- T-0005 | IN_PROGRESS | clone | Phase 3 (tool layer) | only the tool-inventory step is approved; next item needs Soron's go-ahead | 2026-09-26

## Standing constraints (from Soron)
- Do not connect Figma, install `gh`, or connect Gmail, Slack or other communication tools without approval.
- Leave `higgsfield`, `novamira-claude` and any other unknown connector untouched.
- No tasks for the SmartHire50 2026-09-22 observations until Soron asks.
- Visionic uncommitted work: no modify/stage/stash/reset/commit/cleanup without approval.
- No transcript scanning; no `photos-audit` seeding; no WordPress contact without separate approval.

## Completed
- T-0008 | COMPLETED | clone | Phase 3B Master Prompt approval-model consistency update | evidence: CLAUDE.md "Approval model" section plus tightened §2/§3/§9/§10/§11/§13/§17/§20, tools.md §7 corrected, decision 2026-09-26-approval-model active; contradiction search clean; approved by Soron 2026-09-26 including all three judgment calls | 2026-09-26
- T-0006 | COMPLETED | clone | Phase 3.1 tool inventory | evidence: `memory/knowledge/tools.md` written; approved by Soron as documentation 2026-09-26 | 2026-09-26
- T-0007 | COMPLETED | clone | Permission allowlist cleanup | evidence: active `settings.local.json` is valid JSON and exactly matches the reviewed 12 allow + 9 ask lists (checked with jq, SHA-256 prefix 3223bc97498754d7); all 38 original rules accounted for; backup `.bak-2026-09-26` deleted on Soron's instruction; final state reviewed and approved by Soron. Minor process violation: a stray `python3 -V` ran during record-keeping (no effect; acknowledged by Soron, not a security incident) | 2026-09-26
- T-0002 | COMPLETED | clone | Phase 2 memory seeding | evidence: notes written and leak-scanned, project repos verified unchanged (same HEAD and change counts); reviewed and approved by Soron 2026-09-26 | 2026-09-26
- T-0001 | COMPLETED | clone | Phase 1 foundation | evidence: a fresh headless `claude -p` session loaded the Clone, identified Soron and read memory (2026-09-26); approved by Soron | 2026-09-26
