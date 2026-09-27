---
name: tie-aox-roi-calculator
type: project
description: The Implant Engine AOX ROI calculator — React 19 + Vite; logic only in lib/roi.ts with deliberate guards; hand-rolled SVG donut; PDF export; embeddable in an iframe.
updated: 2026-09-27
last_verified: 2026-09-26
paths: [~/Desktop/claude-project/the-implant-engine-aox-roi-calculator-main]
confirmed: inferred
sources:
  - ~/Desktop/claude-project/the-implant-engine-aox-roi-calculator-main (files + git log)
  - ported built-in memory note (2026-08-24), original kept at ~/.claude/projects/-Users-soron-Desktop-claude-project/memory/tie-aox-roi-calculator.md
---

# The Implant Engine: AOX ROI calculator

## Ownership
- Whether TIE is a client: **unknown — confirmation required.**

## Current state (verified from files, 2026-09-26)
- Path: `~/Desktop/claude-project/the-implant-engine-aox-roi-calculator-main`. Remote: `github.com/shourovsoron/ROAS-Calculator`. Branch `main` (tracks `origin/main`). **Working tree clean.**
- Stack: React 19, Vite 6, TypeScript, Tailwind (CDN), lucide-react, html2canvas plus jsPDF for PDF export. `metadata.json` names it "V2 The Implant Engine AOX ROI Calculator".
- **`lib/roi.ts` holds the calculations** (`computeROI`, `buildCostBreakdown`). All three deliberate guards are present and documented in the file header:
  - `profitMargin` divides by `(A || 1)`.
  - `returnOnMarketing` is 0 when marketing spend is 0.
  - `breakEvenArches` is 0 unless pre-marketing profit is strictly positive.
- **The donut is hand-rolled SVG** (`components/CostDonut.tsx`). `recharts` is still in `package.json` but no source file imports it; it appears only in a comment.
- The app posts its height to the parent window (`postMessage` of type `ROAS_IFRAME_HEIGHT`) and the PDF logo links to `https://theimplantengine.com/`.
- A built `dist/` folder exists.
- Secret: `vite.config.ts` injects `GEMINI_API_KEY` from env, and the README says it is expected in `.env.local`. **No source file reads it.** The value was not opened.

**Committed history:** 4 commits on 2026-08-25 ("first commit", "second", "third", "fifth"). "second" rewrote `App.tsx`, "third" added the iframe-height messaging, "fifth" changed CSS.

## Historical (from the 2026-08-24 built-in memory note)
- Redesigned to a new Figma UI on 2026-08-24. Calculations were lifted verbatim out of `App.tsx` into `lib/roi.ts`. Colour and display order belong to the UI; `buildCostBreakdown` returns only name, value and percentage.
- Recharts was replaced because v3's `ResponsiveContainer` measured -1×-1 under React 19 and drew nothing.
- **Math-safety check used then:** bundle `lib/roi.ts` with esbuild to ESM and diff it against a 14-case oracle covering the guard paths (808 assertions). That harness is not in the repo, so rebuild it before touching the formulas.

## Inferred (not confirmed by Soron)
- The iframe-height messaging suggests it is built to be embedded; the host page is unknown.
- The Gemini key setting is left over from the Google AI Studio template (the README is AI Studio boilerplate).
- **Deployment: unknown, not confirmed by Soron.** Don't infer it.

## Conflicts
None. The code matches every claim in the 2026-08-24 note. The 2026-08-25 commits came after that note; they add to it without contradicting it.

## Related
[[figma-is-design-only]], [[tie-eventmark-wordpress]]

## Open questions
- Is TIE a client? Where is the calculator deployed or embedded?

## Next actions
None assigned.
