# Memory schema

Approved by Soron on 2026-09-26. Keep it simple enough to maintain by hand.

## Common header (every note)

```yaml
name: <slug>            # matches filename
type: owner | preference | project | client | knowledge | decision | workflow
description: <one line, used for recall>
updated: YYYY-MM-DD     # last edit to this note
confirmed: soron | inferred   # soron = Soron explicitly confirmed; inferred = read from files/history
sources: [paths or URLs]
```
Project notes also carry `last_verified: YYYY-MM-DD`, the date the Current state section was last checked against its sources.

## Three kinds of information (never merge them)

| Section | Meaning | Rule |
|---|---|---|
| **Current state** | True now and verified (checked against files/tools on `last_verified`, or confirmed by Soron) | Only observable facts or Soron's confirmations. Each fact names its evidence. |
| **Inferred** | Looks likely from files but not confirmed by Soron | Must be labelled. Never promoted to Current state without confirmation or verification. |
| **Historical** | Previously true or previously decided | Dated. Never shown as current. Kept to explain why things changed. |

If code or files contradict a memory note: flag the conflict, cite the evidence, and do **not** silently rewrite history. Record it under the note's "Conflicts" section and raise it with Soron.

## Authority order

1. Soron's current explicit instruction
2. Newest confirmed decision
3. Clone memory (this folder)
4. Project files and configuration
5. Claude built-in memory
6. General assumptions

A conflict that could affect work is raised with Soron, never settled silently.

## Types

| Type | Location / naming | Required | Create new when | Update when | Don't store |
|---|---|---|---|---|---|
| owner | `owner.md` (single) | name, how to address | never | Soron states something new | anything inferred; account-holder details; biography, location or family unless Soron asks |
| preference | `preferences/<topic>.md` | rule, Why, How to apply | a distinct, clearly established rule | refined or reversed | one-time task instructions (if unsure, mark inferred or ask) |
| project | `projects/<slug>.md` (folder if > ~300 lines) | purpose, ownership, location/repo, stack, environments, integrations, current state, inferred, historical, known issues, active decisions, important files, deployment, warnings, next actions, open questions | a project with more than one session of work, or client work | status, issues or decisions change | code structure the repo shows; copies of the project's own CLAUDE.md or README (link instead); secret values |
| client | `clients/<slug>.md` | name, relationship, sites, projects, requirements | first work for a client **whose client status Soron confirmed** | new requirements or decisions | personal data beyond need; message contents |
| decision | `decisions/YYYY-MM-DD-<slug>.md` | context, decision, alternatives, reason, status (`active`/`superseded`), `supersedes`, `superseded_by`, decided_by | an architecture, tech, client, design, workflow or security choice that constrains future work | **never rewritten.** A change creates a new decision; the old one only gets `status: superseded` + `superseded_by` | routine implementation choices |
| knowledge | `knowledge/<domain>-<topic>.md` | facts, sources, date checked | reusable across tasks/projects | new evidence | one-project facts (go in the project note) |
| workflow | `workflows/<slug>.md` | purpose, preconditions, steps, approval points, verification, failure modes | a procedure worked at least once and will repeat | a step changes or fails | untested procedures |
| episode | `episodes/YYYY-MM.md` | date, project, task, what happened, discovered, decision, action, result, lesson, follow-up (~10 lines) | a milestone, failure+fix, decision, discovery or surprise | append only | commands, tool calls, routine edits, raw transcripts |

Project notes list **only active** decisions. Superseded ones stay in `decisions/` for history.

## Tasks

- Board: `tasks/tasks.md`, one line per task: `T-0001 | STATE | project | title | next step | updated | blocked_on | needs`.
- **WAITING_FOR_SORON and BLOCKED tasks must carry `blocked_on`** (what exactly is missing) **and `needs`** (an approval ID from `tasks/approvals.md`, such as `A-0003`, or one specific question for Soron). Other states leave both out.
- Detail file `tasks/T-0001-<slug>.md` only for tasks spanning sessions.
- States: NEW → PLANNING → IN_PROGRESS → WAITING_FOR_SORON → BLOCKED → VERIFYING → COMPLETED → CANCELLED.
- **COMPLETED requires an `evidence:` entry** (verification output, URL checked, test result, or Soron's confirmation). Written code alone is not evidence. No evidence means the task stays VERIFYING.
- CANCELLED requires a one-line reason.

## Approvals

- Log: `tasks/approvals.md`, one line per approval request: `A-0001 | STATE | level | action | target | task | requested | decided | Soron's words | evidence`.
- States: `requested` → `approved` / `denied` → `executed` (with evidence) · `expired` · `cancelled`.
- Create an entry when a WRITE or DESTRUCTIVE action is about to be requested. Record Soron's decision **quoting his words** (briefly), then `executed` with evidence once it's done.
- **Exception (timing only):** a push, and a commit's own approval entry, may be recorded after execution in the next substantive record update (push-record rule, `runtime/PROTOCOL.md` §4). The approval itself must still be given in the conversation before the action; only the log entry is deferred.
- **The log is a record Claude writes, not proof or authority.** Approval happens in the conversation. **A Claude Code permission prompt, including one forced by the guard hook, is never an approval entry.**
- One approval covers the actions and targets it names; it doesn't carry over to other actions, targets or sessions (CLAUDE.md "Approval model", rule 7). DESTRUCTIVE actions are approved immediately before execution.
- Started 2026-09-26. Approvals before that aren't backfilled; see `memory/episodes/`.

## Never

- Secret values anywhere. Record only existence and location ("`GEMINI_API_KEY` is expected in `.env.local`").
- Raw conversation transcripts.
- Content from `photos-audit` (not approved for memory).
