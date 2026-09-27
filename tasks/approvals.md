# Approval log

An audit trail of Soron's approvals for WRITE and DESTRUCTIVE actions (CLAUDE.md "Approval model"). Rules: `memory/SCHEMA.md` → Approvals.

- **Claude writes this log, so it is a record, not proof or authority.** Soron's approval happens in the conversation. Nothing, including the guard hook, treats this file as permission.
- **A Claude Code permission prompt, including one forced by the guard, is not an approval entry.**
- Each entry quotes Soron's own words, briefly. One approval covers the actions and targets it names.
- States: `requested` → `approved` / `denied` → `executed` (with evidence) · `expired` · `cancelled`.
- Started 2026-09-26 on Soron's instruction. Approvals before that are not backfilled; see `memory/episodes/` for earlier history.

`ID | STATE | level | action | target | task | requested | decided | Soron's words | evidence`

## Entries
- A-0001 | executed | WRITE | git commit (Step 0): stage and commit exactly 9 reviewed files | ~/soron-clone | T-0010 | 2026-09-26 | 2026-09-26 | "I approve Step 0's commit only, limited to the exact 9 files listed in your report and the proposed commit message." | commit 07ed5d05b8f6f2d70e6105de66249404f6c6e732; staged set matched; pre-commit passed
- A-0002 | executed | DESTRUCTIVE | git push main (fast-forward c56eba9..07ed5d0) | github.com/shourovsoron/soron-clone | T-0010 | 2026-09-26 | 2026-09-26 | "I explicitly approve pushing commit `07ed5d05b8f6f2d70e6105de66249404f6c6e732` to GitHub `main`." | pre-check: remote at c56eba9, fast-forward; `git ls-remote` after = 07ed5d0
- A-0003 | executed | WRITE | Phase 4.4: record Step 0; create approvals log; add blocked fields to the task board | ~/soron-clone/tasks, memory/episodes | T-0010 | 2026-09-27 | 2026-09-27 | "I approve Phase 4.4 only." | tasks/approvals.md created; task board has blocked_on/needs (T-0003 filled); episode log updated; guard let all record edits through silently
- A-0004 | executed | WRITE | Edit memory/SCHEMA.md: add "Approvals" section and the blocked_on/needs rule (exact diff as shown) | ~/soron-clone/memory/SCHEMA.md | T-0010 | 2026-09-27 | 2026-09-27 | "I approve the exact `memory/SCHEMA.md` diff shown above, and no other changes to that file." | SCHEMA.md diff +11/−1 matches the approved diff exactly; contradiction check clean; guard classifies SCHEMA.md as ask
- A-0005 | approved | WRITE | git commit (Phase 4.4): stage and commit exactly SCHEMA.md, episodes/2026-09.md, tasks.md and approvals.md (including this entry) | ~/soron-clone | T-0010 | 2026-09-27 | 2026-09-27 | "I approve the Phase 4.4 commit, using option (a)." | executed evidence (commit hash) recorded in the next record update
