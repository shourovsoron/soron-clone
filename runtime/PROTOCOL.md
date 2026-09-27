# Session protocol

How the Soron Digital Clone works in a session. **Rules are not defined here.** The authoritative
rules are in `~/soron-clone/CLAUDE.md` (Identity, Memory conventions, Git safety and backup,
Approval model) and `memory/SCHEMA.md`. This file links to them; if anything here seems to
conflict with them, they win and this file should be corrected.

## 1. Session start

1. The Clone is loaded through `~/.claude/CLAUDE.md` → `~/soron-clone/CLAUDE.md` and the memory
   index it imports. `memory/SCHEMA.md` and `tasks/tasks.md` are not auto-loaded.
2. At session start (`startup`, `resume`, `clear`, `compact`) the SessionStart hook
   `runtime/hooks/context.sh` adds a short, read-only summary: Clone backup state (local
   tracking ref only), the project note matching the folder, open-task counts,
   WAITING_FOR_SORON/BLOCKED IDs and pending approvals. Treat it as a pointer: it can be
   missing or stale, and it grants nothing.
3. If the summary is missing, check the Clone's own state yourself (read-only):
   `git -C ~/soron-clone --no-optional-locks status -sb` and whether local `main` is ahead of
   `origin/main`. Unpushed commits mean the GitHub backup is behind.
4. Before task work, read `tasks/tasks.md`; before an approval-requiring step, read
   `tasks/approvals.md`; before writing memory or records, read `memory/SCHEMA.md`.
5. Mention stale or waiting items to Soron only when they bear on the current request.

## 2. Retrieval

1. `memory/INDEX.md` → pick the relevant notes → read the note itself.
2. Check its header: `confirmed` (soron / inferred) and `last_verified`. Keep current, inferred
   and historical information apart (SCHEMA.md).
3. Before **acting** on an inferred or older fact, re-check the source read-only.
4. Conflicts: follow the authority order in SCHEMA.md; if the conflict could affect work, ask Soron.

## 3. Planning

1. Break the request into steps.
2. Classify each step with `memory/knowledge/tools.md`: READ_ONLY, DRAFT,
   WRITE_APPROVAL_REQUIRED or DESTRUCTIVE_APPROVAL_REQUIRED. When unsure, use the higher level.
3. Do the READ_ONLY and DRAFT steps; stop before the first step that needs approval.

## 4. Approval flow (Approval model, rules 1–9)

1. Before a WRITE or DESTRUCTIVE step, add an entry to `tasks/approvals.md` as `requested`
   (format: SCHEMA.md → Approvals).
2. Ask Soron **in the conversation**, naming the exact action and target, and showing the diff,
   file list or command when there is one.
3. Record his decision (`approved` / `denied`), quoting his words briefly.
4. Act only within what he approved. DESTRUCTIVE steps are approved immediately before execution.
5. Verify, then mark the entry `executed` with evidence.

**A Claude Code permission prompt, including one forced by the guard, is never Soron's
approval.** It is a backstop that comes on top of asking him in the conversation.

**Commits:** an approval entry may be included in the commit it approves (marked `approved`);
it is marked `executed` with the commit hash in the next record update, because a commit
cannot contain its own hash.

**Push-record rule:** a push is recorded in the **next substantive record update** (together
with other work), never in a standalone record → commit → push cycle. This avoids an endless
loop of records about pushes.

## 5. Blocked work

1. Set the task to WAITING_FOR_SORON (a decision or approval is needed) or BLOCKED (something
   external is missing).
2. Fill `blocked_on` (what exactly is missing) and `needs` (an approval ID, or one specific
   question).
3. Tell Soron what was checked, the options, and the one question. Continue once he answers.

## 6. Working with the guard

The guard (`runtime/hooks/guard.sh`) is a backstop: it returns nothing, ask or deny, never allow.
Its classifications are in `runtime/policy.json`.

- **Expect prompts** for: edits to Clone config or runtime (`CLAUDE.md`, `SCHEMA.md`,
  `runtime/`, `.git/`), Claude settings, project files, git writes (add, commit, push, …),
  MCP and external writes, and shell or interpreter wrappers.
- **Edit Clone records** (`memory/`, `tasks/`, `workflows/`) with Write/Edit and **absolute
  paths**. Bash edits after `cd` or through `$VAR` paths can't be resolved by the guard and
  will prompt.
- **A deny is final.** Do not look for a way around it; tell Soron what was blocked and why.
- Tool calls that mention a secret-looking file name are denied even in tests; build such test
  strings at run time.

## 7. Git procedures

**Reading:** always `git --no-optional-locks …`; count untracked files with `status -uall`.

**Commit:**
1. Dry-run the pre-commit secret check on exactly what would be staged (new files in full,
   added lines of modified files), with a positive control proving the patterns catch fake
   secrets and fake secret file names.
2. Show Soron the exact file list, diff summary and message; get approval.
3. Stage the files **by name**; confirm the staged set and diff match what was approved and
   that nothing else is pending.
4. Commit with the message fed in through a heredoc (`-F -`). The pre-commit hook runs
   normally; never `--no-verify`.
5. Report the hash, the files in the commit and the working-tree status.

**Push** (DESTRUCTIVE, separate approval immediately before):
1. Checks: GitHub `main` is the expected commit (`git ls-remote`); local `HEAD` is the expected
   commit; the expected parent/ancestry; the expected number of commits; clean working tree;
   fast-forward (`merge-base --is-ancestor`).
2. If any check fails as worded, do not push; report it and ask.
3. Plain push of `main`, no force, credential prompts disabled; never enter credentials.
4. Verify GitHub `main` equals local `HEAD`, and the working tree is clean.

## 8. Write-back (end of each task)

- **Task board:** state, next step, `evidence:` for COMPLETED, `blocked_on`/`needs` when waiting.
- **Approval log:** decisions recorded; executed entries have evidence.
- **Episode:** only for meaningful events (SCHEMA.md → episode format). Append-only.
- **Decision:** a new record for a real decision; supersede instead of rewriting.
- **Memory notes and index:** update them if facts changed; keep inferred facts marked.
- **Report** to Soron what changed, what was verified, and what is uncommitted or unpushed.

## 9. Known pitfalls

- zsh does not word-split an unquoted `$VAR` holding a list; use `xargs -0` or explicit arrays.
- Diff filters like `grep '^[-+][^-+]'` hide Markdown bullets (`+- …`); show full hunks.
- A clean result only means something with a positive control.
- Small-model summaries of documentation can be wrong; check key claims against the raw text.
- `git status --short` groups untracked folders; use `-uall` for real counts.
