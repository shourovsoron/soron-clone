# Setup and restore

How to set up the Soron Digital Clone on a new Mac or under a new Claude account. **This file
contains no secrets and must never contain any.** It documents where things go; credentials and
sign-ins are done by Soron in the relevant app, never written here.

Rules live in `~/soron-clone/CLAUDE.md` (Approval model, Standing constraints). Follow them during
setup too: each step that changes configuration needs Soron's approval, and a Claude Code
permission prompt is never that approval.

## 1. Requirements

- macOS with `/bin/bash` (3.2 is fine) and `/usr/bin/jq`
- git
- Claude Code

## 2. Get the Clone

```
git clone https://github.com/shourovsoron/soron-clone.git ~/soron-clone
```

The path matters: the hook commands below use absolute paths to `~/soron-clone`.

## 3. Repo-local git identity (never global)

```
git -C ~/soron-clone config user.name "Shourov Hossain Soron"
git -C ~/soron-clone config user.email "71521705+shourovsoron@users.noreply.github.com"
```

## 4. Pre-commit secret scan

The scan is version-controlled at `runtime/git-hooks/pre-commit`. Link it into git's hooks folder:

```
ln -s ../../runtime/git-hooks/pre-commit ~/soron-clone/.git/hooks/pre-commit
```

Do **not** use `git config core.hooksPath`: the guard denies it, because it is also how the scan
could be switched off. Never bypass the scan with `--no-verify` without Soron's approval.

## 5. Load the Clone in every session: `~/.claude/CLAUDE.md`

The file contains exactly one line:

```
@~/soron-clone/CLAUDE.md
```

## 6. Permissions and hooks: `~/.claude/settings.json`

Add these two keys and **merge** them with any existing settings. Don't replace the file. Adjust
`/Users/soron` if the home folder differs.

```json
{
  "permissions": {
    "ask": [
      "Bash(git push *)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/soron/soron-clone/runtime/hooks/guard.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/soron/soron-clone/runtime/hooks/context.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

- `permissions.ask`: every `git push` prompts, even in auto mode.
- `PreToolUse`: the guard (`runtime/hooks/guard.sh`). It is a backstop that returns nothing, ask or
  deny, never allow.
- `SessionStart`: the read-only context summary (`runtime/hooks/context.sh`). It grants nothing.

## 7. Verify

```
~/soron-clone/runtime/tests/run.sh
~/soron-clone/runtime/tests/run-context.sh
```

Expected: guard suite all pass with `allow_decisions=0`; context suite all pass. Then run `/hooks`
in a terminal Claude Code session to see both hooks, and open a new session to see the context
block.

## 8. Per-account steps (not in the repo)

- Connector sign-ins (the Novamira connectors; Figma only if Soron approves it) are done by Soron
  in Claude Code's connector settings.
- Account-bound items do not move with the Clone: claude.ai artifacts, Claude Docs, scheduled tasks
  and Claude's built-in memory. Durable knowledge belongs in `~/soron-clone`.

## 9. What the repo does not contain

`~/.claude/settings.json`, `~/.claude/CLAUDE.md`, the `.git/hooks/pre-commit` symlink, connector
credentials, Claude's built-in memory, and the project repositories themselves.

## 10. Portability limits (known, not yet fixed)

These are tied to this Mac and user and need adjusting on a different machine or username:

- `runtime/policy.json`: scratchpad prefix `/private/tmp/claude-501/` (macOS user ID 501).
- `runtime/tests/run.sh`: a fixed scratchpad path from the session that wrote it.
- `runtime/tests/cases.jsonl`: absolute `/Users/soron/...` paths.

Until they are adjusted, some guard test cases can fail on another machine. The context tests
(`run-context.sh`) use `{HOME}` placeholders and are not affected.

## 11. Rollback

- Remove the `SessionStart` or `PreToolUse` entry from `hooks` in `~/.claude/settings.json`, or set
  `"disableAllHooks": true` (this disables both). Removing `SessionStart` also means restoring the
  `@memory/SCHEMA.md` and `@tasks/tasks.md` imports in `CLAUDE.md`.
- Pre-commit: replace the symlink with a copy
  (`cp ~/soron-clone/runtime/git-hooks/pre-commit ~/soron-clone/.git/hooks/pre-commit`).
