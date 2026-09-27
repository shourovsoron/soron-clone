# Memory index

One line per note. Rules: [SCHEMA.md](SCHEMA.md). Notes marked *(inferred)* are not yet confirmed by Soron. Read the note before relying on it.

## Owner
- [owner](owner.md) — Soron; minimal by design.

## Preferences
- [figma-is-design-only](preferences/figma-is-design-only.md) — **confirmed**. Figma is primarily a visual reference; don't blindly copy numbers, dimensions or spacing; use judgment and project constraints (project rules win).
- [communication-style-profile](preferences/communication-style-profile.md) — **confirmed**. Writing-style reference for drafting messages in Soron's voice (short Banglish, one-word acknowledgements, little emoji); style only, never a source of facts, opinions or decisions; never sent without Soron's approval.

## Projects
- [visionic-agency](projects/visionic-agency.md) *(inferred)* — Next.js 16 plus planned headless WordPress; home sections in progress; **baseline 5 modified + 46 untracked (confirmed): don't touch**; WordPress not connected; deployment unknown.
- [smarthire50-site](projects/smarthire50-site.md) *(inferred)* — WorkScout job board; 200 LinkedIn jobs imported 2026-09-22; ownership unknown.
- [tie-aox-roi-calculator](projects/tie-aox-roi-calculator.md) *(inferred)* — ROI calculator; logic only in `lib/roi.ts`, deliberate guards, SVG donut, iframe-embeddable.
- [tie-eventmark-wordpress](projects/tie-eventmark-wordpress.md) *(inferred)* — claude.eventmark.design; Elementor Free pages built via PHP; environment unknown.
- [spin-and-win-campaign](projects/spin-and-win-campaign.md) *(inferred)* — Next.js plus MongoDB prize wheel, 800-prize transactional engine; its export feeds prize-spinner.
- [prize-spinner](projects/prize-spinner.md) *(inferred)* — client-only CSV raffle draw, localStorage state.

## Small experiments (no note: nothing reusable found)
- `~/Desktop/claude-project/portfolio-showcase` — "Portfolio Showcase — Motion Prototype" (static HTML plus a tiny Node server, 2026-09-10).
- `~/Desktop/claude-project/diverging-slider` — "Diverging Gallery Slider — GSAP" (static HTML, 2026-09-10).

## Clients
_(none: every client relationship is unconfirmed)_

## Decisions
- [2026-09-27-clone-architecture-precommit-no-bypass](decisions/2026-09-27-clone-architecture-precommit-no-bypass.md) — **active**. Git repo `~/soron-clone`, authoritative memory, schema; private GitHub backup (`shourovsoron/soron-clone`), commit and push only with approval; version-controlled pre-commit scan (symlinked from `.git/hooks`; setup in `runtime/SETUP.md`); Claude never bypasses it, only Soron can.
- [2026-09-27-clone-architecture-versioned-precommit](decisions/2026-09-27-clone-architecture-versioned-precommit.md) — **superseded** by the above (was: `--no-verify` "without Soron's approval", which the guard never allowed).
- [2026-09-26-clone-architecture-github-backup](decisions/2026-09-26-clone-architecture-github-backup.md) — **superseded** by the above (was: pre-commit hook not version-controlled).
- [2026-09-26-clone-memory-architecture](decisions/2026-09-26-clone-memory-architecture.md) — **superseded** by 2026-09-26-clone-architecture-github-backup (was: local-only git).
- [2026-09-26-clone-guard-hook](decisions/2026-09-26-clone-guard-hook.md) — **active**. Global PreToolUse guard (`runtime/hooks/guard.sh`; none, ask or deny, never allow) plus global `Bash(git push *)` ask rule; verified live.
- [2026-09-27-session-context-hook](decisions/2026-09-27-session-context-hook.md) — **active**. Global SessionStart hook (`runtime/hooks/context.sh`; read-only state and pointers); CLAUDE.md imports only INDEX.md; standing constraints moved into CLAUDE.md; verified live.
- [2026-09-26-approval-model](decisions/2026-09-26-approval-model.md): **active**. Four levels; project changes, every git write and external writes need approval; Claude Code allow/ask is never Soron's approval.
- [2026-09-26-tie-elementor-constraints](decisions/2026-09-26-tie-elementor-constraints.md) — **active, TIE only**. No Pro widgets, no HTML widgets, Containers over Inner Sections.

## Knowledge
- [permission-allowlist-review](knowledge/permission-allowlist-review.md) *(inferred)*: 38 pre-approved Claude Code rules reviewed; cleanup applied and approved 2026-09-26: 12 allow + 9 ask; 18 removed; backup deleted.
- [tools](knowledge/tools.md) — **confirmed**: tool inventory, approval levels, WordPress/git/browser rules, pre-approved-command warning, secret names only.
- [wordpress-novamira-elementor](knowledge/wordpress-novamira-elementor.md) *(inferred)* — Novamira upload/lint flow, sandbox safe-mode risk, Elementor Free gotchas.
- [figma-mcp-view-seat-workaround](knowledge/figma-mcp-view-seat-workaround.md) *(inferred)* — inspect a public Figma file in the browser when the MCP is rate-limited.

## Workflows
_(none yet. Candidate: the SmartHire50 LinkedIn job import, if it will repeat)_

## Excluded by decision
- `photos-audit`: not seeded (personal data; needs separate approval).
- Session transcripts: not scanned (needs separate approval; never stored raw).

## Episodes
- [2026-09](episodes/2026-09.md) — Clone first run, Phases 1–4 (Phase 4 completed 2026-09-27).
