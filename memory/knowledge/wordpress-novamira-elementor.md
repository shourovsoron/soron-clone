---
name: wordpress-novamira-elementor
type: knowledge
description: How to safely build WordPress/Elementor Free pages through the Novamira MCP — upload/lint flow, sandbox behaviour, Elementor Free gotchas.
updated: 2026-09-26
confirmed: inferred
sources:
  - split from the tie-eventmark-wordpress built-in memory note (2026-09-16)
  - smarthire50-linkedin-import-report.md (2026-09-22)
---

Learned on claude.eventmark.design (as of 2026-09-16). Re-check before relying on it.

- **Novamira tools:** `mcp-adapter-discover-abilities`, `mcp-adapter-get-ability-info` and `mcp-adapter-execute-ability`. Abilities include `novamira/execute-php`, `write-file` and `create-upload-link`. **`execute-php` can write, so treat it as a write tool.**
- **Uploading large PHP safely:** get a link from `novamira/create-upload-link`, curl the file to `sandbox/staging/*.txt`, lint it with `php -l` through `execute-php`, and only then rename it to `.php`. Sandbox files load on every request, and a fatal error puts the site into safe mode.
- **Elementor at the mobile breakpoint** forces child containers to `--width:100%`. Always set `width_mobile` / `width_tablet` on fixed-width badges and "grow" columns.
- **Per-element Custom CSS is Pro-only.** On Elementor Free, add page-scoped CSS with `wp_add_inline_style` from a sandbox file.
- On smarthire50.com (2026-09-22), the admin-access-link ability became unavailable partway through; `execute-php` and the upload endpoint still worked.
