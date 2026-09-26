---
name: figma-is-design-only
type: preference
description: Figma is primarily a visual/design reference — don't blindly copy arbitrary numbers, dimensions, spacing or implementation details; use judgment and the project's real constraints.
updated: 2026-09-26
confirmed: soron
sources: [Soron's confirmation 2026-09-26; earlier rule from a 2026-08-24 session]
---

## Current (confirmed by Soron, 2026-09-26; permanent preference)
Figma is primarily a **visual/design reference**. Do not blindly copy arbitrary numbers, dimensions, spacing values or implementation details from Figma. Use judgment and the project's actual implementation constraints.

**Scope:** this is about implementation judgment. It does **not** mean Figma is never authoritative. Where a project's own instructions set a stricter fidelity rule, that project rule wins for that project (project requirements rank above general preferences). For example, Visionic's CLAUDE.md says to match Figma closely.

**How to apply:**
- Treat values in Figma as design intent, not as data or specifications to paste in.
- Placeholder or sample figures (mock metrics, sample numbers) must not appear as real output. Derive them from real logic, or ask whether to omit them.
- When a Figma value conflicts with the project's layout system, tokens or constraints, prefer a coherent implementation and mention the difference.

## Historical (2026-08-24 session, ROI calculator; stated by an unconfirmed person)
The narrower rule used then: "Skip Figma's data, Figma just for design", and every displayed number must be input-driven. It is superseded by the confirmed wording above and kept here for context. See [[tie-aox-roi-calculator]].
