---
name: tie-eventmark-wordpress
type: project
description: The Implant Engine site on claude.eventmark.design — WordPress + Elementor Free, pages generated via PHP through Novamira. Environment and client status unknown.
updated: 2026-09-27
last_verified: 2026-09-26
paths: []
confirmed: inferred
sources:
  - ported built-in memory note (last modified 2026-09-16), original kept at ~/.claude/projects/-Users-soron-Desktop-claude-project/memory/tie-eventmark-wordpress.md
---

# The Implant Engine site (claude.eventmark.design)

## Ownership and environment
- Whether TIE is a client: **unknown — confirmation required.**
- Whether `claude.eventmark.design` is staging or production: **unknown — confirmation required.** Soron has not confirmed it (2026-09-26). Do not contact the site just to find out.

## Current state (verified 2026-09-26)
- A Novamira connector for this site is connected in Claude (`novamira-claude-eventmark`). A second entry, `novamira-claude`, needs sign-in; leave it untouched.
- **The live site was not inspected** during seeding. Everything below is historical.

## Historical (as of 2026-09-16, from the built-in memory note)
- **Stack:** Elementor Free 4.x plus Hello Elementor. Pages are generated programmatically (Elementor JSON via PHP), not in the editor.
- **Sandbox helpers** in `wp-content/novamira-sandbox/`:
  - `tie-build-helpers.php` (`tie_c`, `tie_w`, `tie_typo`, `tie_set_section`)
  - `tie-brand-fonts.php` (loads Satoshi from Fontshare)
- **Blog single page** (ID 149, slug `increase-all-on-x-consult-show-up-rate`) is built by `tie-blog-components.php`, `tie-blog-content.php` and `tie-blog-page.php`; `tb_build_blog_page()` rebuilds it.
- Hero and footer come from existing templates or other agents' work.
- Earlier scope rules for that work: no Elementor Pro, no HTML-widget shortcuts, no theme-builder templates. Superseded by the confirmed project rules below; "no theme-builder templates" remains unconfirmed.
- Reusable technique: [[wordpress-novamira-elementor]]. Figma rate-limit workaround: [[figma-mcp-view-seat-workaround]].

## Active decisions
- [[2026-09-26-tie-elementor-constraints]]: no Elementor Pro widgets, no HTML widgets, Containers over Inner Sections. **Project-specific; not global.**

## Open questions
- Is TIE a client? Is this staging or production?

## Next actions
None assigned.
