---
name: visionic-agency
type: project
description: Visionic Agency website — Next.js 16 front end with WordPress as a headless CMS (planned); home-page sections in progress with significant uncommitted work.
updated: 2026-09-26
last_verified: 2026-09-26
confirmed: inferred
sources:
  - ~/Projects/visionic-agency/CLAUDE.md
  - ~/Projects/visionic-agency/package.json
  - git log / git status (read with --no-optional-locks)
---

# Visionic Agency website

**Project instructions live in the repo:** `~/Projects/visionic-agency/CLAUDE.md` (about 50 sections: architecture, WordPress rules, GSAP, SEO, accessibility, Figma rules). Read that file before any work. This note does not copy it.

## Ownership
- Owner / client: **unknown — confirmation required.** The project CLAUDE.md calls it "the official Visionic Agency website".

## Current state (verified from files, 2026-09-26)

**Repository**
- Path: `~/Projects/visionic-agency`. Remote: `github.com/shourovsoron/Visionic-v2`. Branch: `main` (tracks `origin/main`). No stashes.
- Stack in `package.json`: Next.js 16.3.4, React 19.2.8, Tailwind v4, shadcn, `@base-ui/react`, GSAP 3.15, lucide-react. No `src/` directory.
- No `.env*` files are present. `next.config.ts` is empty (default).
- **WordPress is not yet connected in the local project** (finding confirmed by Soron on 2026-09-26; keep it unless later evidence shows otherwise). `lib/wordpress/` does not exist. Projects come from a static stand-in (`lib/projects/static.ts`), and code comments mark FAQs and testimonials as "WordPress later".
- Integration in code: Cal.com inline booking embed (`components/sections/contact/CalEmbed.tsx`).

**Committed history** (7 commits, 2026-09-03 → 2026-09-13)
- 09-03: create-next-app, first commit
- 09-10: "hero complete without animation", "fix deployment", "fix deployment author", "Bottom Navigation Fix"
- 09-13 (latest): "3 new section design no existing fixing"

**Uncommitted working state. Baseline confirmed by Soron on 2026-09-26: 5 modified + 46 untracked.** Do not modify, stage, stash, reset, commit or clean up without Soron's approval.
- 5 modified tracked files (+105 / −12 lines): `app/globals.css`, `app/layout.tsx`, `app/page.tsx`, `components/sections/FeaturedProjects.tsx`, `lib/navigation.ts`.
- 46 untracked files: 12 components (`navigation/Footer`, `NewsletterForm`, `sections/Contact`, `Faq`, `Pricing`, `Process`, `Testimonials` and their sub-components, `contact/CalEmbed`) plus 34 assets under `public/` (contact, faq, footer, icons, logos, pricing, process, testimonials).
- Status of this work: **unknown**. Do not classify it as completed, abandoned or experimental unless Soron confirms.

## Inferred (not confirmed by Soron)
- The site is built section by section from a Figma design (code comments cite Figma node IDs such as 6578:5129).
- A headless WordPress backend is planned (per the project CLAUDE.md). Its URL and content model are unknown.

## Deployment
- **Unknown, not confirmed by Soron.** Don't infer it from commit messages.

## Active decisions
None recorded as decision notes yet. Architecture rules are stated in the project CLAUDE.md, for example: REST API only (no WPGraphQL), Next.js owns navigation and layout, WordPress only for dynamic content, BottomNavigation lives in the root layout.

## Warnings
- Uncommitted work (above) is not backed up to the remote.
- Git author metadata contains personal details. Not copied here.

## Conflicts
- **Project CLAUDE.md §49 vs git history.** §49 says the project is in "foundational setup phase — do NOT build the actual website pages yet", but committed and uncommitted history shows home-page sections being built (hero, featured projects, contact, FAQ, pricing and others). The §49 text is probably out of date. Ask Soron; don't edit the project file.

## Open questions
- Is Visionic Agency Soron's own business, or a client's?
- Where is the site deployed (unknown)? What is the WordPress backend URL?
- What is the status of the uncommitted work?

## Next actions
None assigned. Wait for Soron.
