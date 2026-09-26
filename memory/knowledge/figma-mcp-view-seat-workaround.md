---
name: figma-mcp-view-seat-workaround
type: knowledge
description: Workaround when the Figma MCP is rate-limited on a View seat — inspect the public file in the built-in browser and calibrate font sizes by measurement.
updated: 2026-09-26
confirmed: inferred
sources:
  - split from the tie-eventmark-wordpress built-in memory note (2026-09-16)
---

As of 2026-09-16: the Figma MCP was rate-limited on the account's **View** seat. A seat change or a different account may remove the limit.

**Workaround that worked:**
- If the Figma file is public, open it in the built-in browser. Keyboard shortcuts don't reach Figma there, so use the zoom dropdown menu and drag to pan.
- To get exact font sizes, measure text widths in Figma and compare them with the same text rendered in the browser (Satoshi at 100px).
