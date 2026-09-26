---
name: prize-spinner
type: project
description: Prize Spinner — client-only Next.js raffle draw: import participant CSV, configure prizes, spin for one random winner at a time; state in localStorage. Ownership unknown.
updated: 2026-09-26
last_verified: 2026-09-26
confirmed: inferred
sources:
  - ~/Desktop/claude-project/prize-spinner/README.md
  - git log / status
---

# Prize Spinner

## Ownership
- Ownership / client: **unknown.**

## Current state (verified from files, 2026-09-26)
- Path: `~/Desktop/claude-project/prize-spinner`. Remote: `github.com/shourovsoron/raffle-draw`. Branch `main`. **Working tree clean.**
- Stack: Next.js (App Router), React, TypeScript, Tailwind. No backend, no database, no env files.
- **Flow:** CSV → participants → select prize → spin → one random winner → winner removed from the pool → that prize's remaining count drops by 1.
- **Phone column is the unique identity**; it's auto-detected and normalized. Duplicate phones are merged, keeping the first row.
- **Integrity rules** live in `lib/draw.ts` (`drawReducer`):
  - A participant can win once per draw.
  - A prize with zero remaining can't be awarded.
  - A prize's quantity can't be edited below its current winner count.
  - Picks use `crypto.getRandomValues` with rejection sampling, so there's no modulo bias.
  - A winner is committed only after the reel animation finishes.
- **Persistence:** localStorage key `prize-spinner-state`, validated on load, and saves wait until hydration. Eligibility is always derived, never stored.
- A dev-server launch entry exists in `~/Desktop/claude-project/.claude/launch.json` (port 3000).
- **Committed history:** 2 commits on 2026-09-19, "first commit" and "fix storage problem".

## Relationship
- Accepts the [[spin-and-win-campaign]] admin CSV export as-is (stated in the README; a sample is in `public/sample-participants.csv`).

## Open questions
- Who is it for? Has it been used at a live event?

## Next actions
None assigned.
