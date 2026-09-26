---
name: 2026-09-26-approval-model
type: decision
description: The Clone's approval model — four levels; project changes, every git write, and external writes need Soron's approval; Claude Code allow/ask permissions never count as Soron's approval.
updated: 2026-09-26
confirmed: soron
sources: [Soron's instructions 2026-09-26; ~/soron-clone/CLAUDE.md "Approval model"]
status: active
supersedes: null
superseded_by: null
decided_by: Soron
---

**Context:** the original Master Prompt allowed "preparing code changes" and "safe diagnostics" without asking, asked about commits only "when consequences are significant", and allowed standing permission per type of communication. The Claude Code allowlist also pre-approved write-capable commands.

**Decision:** the full text is the "Approval model" section of `~/soron-clone/CLAUDE.md`. In short:
1. Any project modification needs approval before execution. Reads stay READ_ONLY.
2. Every git commit, and every other git write, needs approval. Destructive git operations stay DESTRUCTIVE.
3. Claude Code's pre-approved permissions are not Soron's approval.
4. Claude Code's `ask` list is an extra layer, not a replacement.
5. External-system writes need approval immediately before execution.
6. Destructive or irreversible actions need explicit approval immediately before execution, even if discussed earlier.
7. The four levels stay: READ_ONLY, DRAFT, WRITE_APPROVAL_REQUIRED, DESTRUCTIVE_APPROVAL_REQUIRED.
8. No existing safety rule is weakened.

**Alternatives:** keep the Master Prompt's original "significant consequences" wording (rejected as too vague).

**Reason:** one unambiguous approval rule that doesn't depend on Claude Code's permission configuration.
