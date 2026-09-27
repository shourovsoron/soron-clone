---
name: smarthire50-site
type: project
description: smarthire50.com — WordPress job board (WorkScout + WP Job Manager); 200 LinkedIn jobs imported on 2026-09-22. Ownership unknown.
updated: 2026-09-27
last_verified: 2026-09-26
paths: []
confirmed: inferred
sources:
  - ~/Desktop/claude-project/smarthire50-linkedin-import-report.md (dated 2026-09-22)
---

# SmartHire50 site

## Ownership
- Owner / client: **unknown — confirmation required.**

## Current state (verified 2026-09-26)
- Site URL: https://smarthire50.com
- A Novamira MCP connector for this site is connected in Claude (`novamira-smarthire50-com`).
- **The live site was not inspected** during seeding (no WordPress contact was allowed). Everything below comes from the 2026-09-22 report and describes the site **as of that date**.

## Historical (as of 2026-09-22, from the import report)
- **Stack:** WorkScout theme plus WorkScout Core, WP Job Manager, Elementor.
- **Work done:** imported 200 LinkedIn jobs (5 in each of 40 new categories, term IDs 121–160), authored by the employer account **user ID 2** (login email intentionally not stored). The report records verification for all 200: apply link, logo, author, publish status, one category each.
- **How the Apply button works:** WorkScout Core's per-job `_apply_link` field holds the exact LinkedIn URL, with `_application` as a fallback. The 22 pre-existing jobs (IDs 287–308, user ID 1) have an empty `_apply_link`, so they keep the standard application popup. No global change was made.
- **Logos:** stored with WP Job Manager's `_company_logo` plus a featured image. Each has `_smarthire_logo_source` meta recording where it came from.
- **Rules used for the import:** data only from public LinkedIn job pages; nothing invented; salary only when shown as a numeric range; unclear job types left empty; no LinkedIn login or CDN scraping; parent-company logos not allowed.
- **Left untouched:** 10 demo categories, existing jobs, users, plugins, theme and settings.

## Issues reported on 2026-09-22 (historical/investigative only; current status unknown)
Soron decided on 2026-09-26: **do not create tasks** for these until explicitly asked to track or resolve them.
1. Elementor "Coming Soon" mode was on, so the public site was visible only to logged-in users.
2. The theme's default placeholder company logo pointed to a dead URL on a `cloudwaysapps.com` host.
3. Imported jobs expire 60 days after creation (around 2026-11-21) and LinkedIn postings may close earlier. The report recommended periodic checks.
4. The Novamira admin-access-link ability became unavailable partway through; work continued via `execute-php` and the upload endpoint.

## Inferred (not confirmed by Soron)
- Hosting is Cloudways (from the placeholder-logo URL).
- Whether this is production or staging is unknown, although "Coming Soon" mode suggests it had not launched.

## Candidate workflow
The LinkedIn job import procedure worked once and is documented in the report. Promote it to `workflows/` only if Soron expects to repeat it.

## Open questions
- Is SmartHire50 Soron's own site or a client's?

## Next actions
None assigned.
