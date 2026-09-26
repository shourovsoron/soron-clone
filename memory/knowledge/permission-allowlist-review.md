---
name: permission-allowlist-review
type: knowledge
description: Read-only security review (2026-09-26) of the 38 pre-approved Claude Code rules in ~/Desktop/claude-project/.claude/settings.local.json, with a category and recommendation for each. No permission was changed.
updated: 2026-09-26
last_verified: 2026-09-26
confirmed: inferred   # findings by Claude; decisions pending Soron
sources:
  - /Users/soron/Desktop/claude-project/.claude/settings.local.json (read only; last modified 2026-09-14)
  - existence checks of the paths the rules reference
---

# Permission allowlist review

**Status:** inspection only. **No rule has been changed.** Soron decides.

## Where the rules are and where they apply

- **File:** `/Users/soron/Desktop/claude-project/.claude/settings.local.json`. Its only key is `permissions.allow` (38 rules). There are no `deny` or `ask` lists.
- **Scope:** Claude Code sessions whose **project folder is `~/Desktop/claude-project`**, including work in its subfolders (spin-and-win, prize-spinner, the ROI calculator, and so on) from such a session. This session is one of them.
  - It does **not** apply to sessions opened directly in `~/Projects/visionic-agency`, in `~/soron-clone`, or in a subproject folder opened as its own project. None of those has a permission file.
  - `.local.json` means a personal file, not shared.
- **Other permission sources checked:**
  - `~/.claude/settings.json`: no permission keys.
  - `~/.claude.json`: no per-project allowed tools.
  - No managed settings file; no `.claude/settings*.json` in Visionic or in the other subprojects (spin-and-win has only `launch.json`).
- **How matching works** (from Claude Code's documented behaviour; **not tested**, since testing would mean running the rules):
  - `Bash(x *)` means "starts with `x `, followed by anything".
  - A rule with no `*` must match exactly.
  - Commands joined with `&&`, `;` or `|` are checked piece by piece.
  - `Read(//path/**)` allows the Read tool on anything under that absolute path.
- **Caveat:** the session's permission mode (for example auto mode) also decides what runs without a prompt. The allowlist is one layer. The Clone's approval model in [[tools]] is followed whether or not a prompt appears.

## Categories and recommendations used

- **Categories:** SAFE_READ · LOCAL_WRITE · EXTERNAL_WRITE · DESTRUCTIVE · SECRET_RISK · NEEDS_REVIEW (the most serious one that applies is shown).
- **Recommendations:**
  - KEEP: harmless, may stay pre-approved.
  - NARROW: replace with a tighter pattern.
  - REQUIRES_EXPLICIT_APPROVAL: a real capability that's still needed sometimes; take it off the allowlist and ask each time.
  - REMOVE: an obsolete one-off, or dangerous and not needed.

**Columns:** R = can read files · M = can modify files · S = can reach secrets · X = can affect external systems/network · I = can install software · D = can delete or overwrite · A = can run arbitrary code indirectly. Y / N / (Y) = only in some uses.

| # | Rule (exact) | What it permits | R | M | S | X | I | D | A | Category | Recommendation |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | `Read(//Users/soron/Downloads/**)` | Read tool on everything in Downloads | Y | N | Y | N | N | N | N | **SECRET_RISK** | REQUIRES_EXPLICIT_APPROVAL: Downloads can hold personal documents and keys; grant per task |
| 02 | `Bash(nohup python3 -m http.server 4173)` | Background HTTP server for the **current folder**, on **all network interfaces** (Python's default) | Y | N | Y | Y | N | N | N | **SECRET_RISK** | REMOVE. Run from `claude-project` it would serve every subfolder, **including `spin-and-win-campaign/.env.local`**, to the local network |
| 03 | `Bash(curl -s -o /dev/null -w "%{http_code}\\n" http://localhost:4173/index.html)` | Status check on localhost | N | N | N | N | N | N | N | SAFE_READ | KEEP (obsolete but harmless) |
| 04 | `Bash(which node *)` | Look up program paths | N | N | N | N | N | N | N | SAFE_READ | KEEP |
| 05 | `Bash(pkill -f "http.server 4173")` | Kill processes whose command line matches | N | N | N | N | N | (Y) | N | LOCAL_WRITE | REMOVE (goes with 02) |
| 06 | `Bash(nohup node portfolio-showcase/server.mjs)` | Run a **relative-path** script as a background server (listens on all interfaces, serves its own folder) | Y | N | N | Y | N | N | (Y) | NEEDS_REVIEW | REMOVE. Relative path means whatever file has that name in the current folder runs; the `launch.json` preview covers this use |
| 07 | `Read(//private/tmp/claude-501/**)` | Read every Claude session scratchpad for this user | Y | N | (Y) | N | N | N | N | SAFE_READ | KEEP (the current scratchpad is readable anyway; old scratchpads may hold copies of data, so NARROW is also reasonable) |
| 08 | `Bash(npm install *)` | Install any package; `-g` for global; git or tarball sources | Y | Y | Y | Y | **Y** | Y | **Y** | **EXTERNAL_WRITE** | REQUIRES_EXPLICIT_APPROVAL. Install scripts run arbitrary code and it changes the lockfile and `node_modules` |
| 09 | `Bash(npm audit *)` | `npm audit` (read), but also **`npm audit fix` / `--force`** (upgrades and installs) | Y | (Y) | N | Y | (Y) | (Y) | (Y) | NEEDS_REVIEW | NARROW to `Bash(npm audit)` and `Bash(npm audit --json)` |
| 10 | `Bash(python3 -c ' *)` | **Any Python code** | Y | Y | Y | Y | Y | Y | **Y** | **DESTRUCTIVE** + SECRET_RISK | REQUIRES_EXPLICIT_APPROVAL. Effectively unrestricted code execution |
| 11 | `Bash(npm view *)` | Read package metadata from the registry | N | N | N | Y (read) | N | N | N | SAFE_READ | KEEP |
| 12 | `Bash(npx tsc *)` | TypeScript compiler; **writes output files** unless `--noEmit`; `npx` may **download the unrelated `tsc` package** if TypeScript isn't installed locally | Y | Y | N | (Y) | (Y) | (Y) | (Y) | NEEDS_REVIEW | NARROW to `Bash(npx --no-install tsc --noEmit)` (or with `-p <path>`) |
| 13 | `Bash(npx next *)` | `next dev`, `build`, `start`, etc. Runs project code; **rewrites project files** (`next-env.d.ts`, the `AGENTS.md` block); may download | Y | Y | Y | Y | (Y) | Y | **Y** | NEEDS_REVIEW | REQUIRES_EXPLICIT_APPROVAL. Would touch Visionic's protected working tree |
| 14 | `Bash(brew list *)` | List installed packages | N | N | N | N | N | N | N | SAFE_READ | KEEP |
| 15 | `Bash(docker rm *)` | Remove containers (`-f` running ones, `-v` their volumes) | N | Y | N | N | N | **Y** | N | **DESTRUCTIVE** | REQUIRES_EXPLICIT_APPROVAL |
| 16 | `Bash(docker run *)` | Run any image. It can **mount the whole disk** (`-v /:/host`), run `--privileged`, use the network and pull images | Y | Y | Y | Y | Y | Y | **Y** | **DESTRUCTIVE** + SECRET_RISK | REQUIRES_EXPLICIT_APPROVAL |
| 17 | `Bash(docker info *)` | Docker status | N | N | N | N | N | N | N | SAFE_READ | KEEP |
| 18 | `Bash(echo "EXIT:$?")` | Print the last exit code | N | N | N | N | N | N | N | SAFE_READ | KEEP |
| 19 | `Bash(brew tap *)` | Add any third-party formula repository (clones from anywhere) | N | Y | N | Y | **Y** | N | (Y) | **EXTERNAL_WRITE** | REQUIRES_EXPLICIT_APPROVAL |
| 20 | `Bash(brew install *)` | Install any formula or cask (runs its install code) | Y | Y | Y | Y | **Y** | Y | **Y** | **EXTERNAL_WRITE** | REQUIRES_EXPLICIT_APPROVAL |
| 21 | `Bash(brew untap *)` | Remove a formula repository | N | Y | N | N | N | Y | N | LOCAL_WRITE | REQUIRES_EXPLICIT_APPROVAL |
| 22 | `Bash(sw_vers -productVersion)` | macOS version | N | N | N | N | N | N | N | SAFE_READ | KEEP |
| 23 | `Bash(mkdir -p /tmp/mongo-test)` | Create a folder | N | Y | N | N | N | N | N | LOCAL_WRITE | REMOVE (obsolete: `/tmp/mongo-test` is gone) |
| 24 | `Read(//tmp/**)` | Read tool on all of `/tmp`, which is shared with other apps | Y | N | **Y** | N | N | N | N | **SECRET_RISK** | REMOVE. `/tmp` holds other apps' temp files and was the target of rule 29; rule 07 covers the scratchpad |
| 25 | `Bash(curl -fsSL -o mongodb.tgz "https://fastdl.mongodb.org/…7.0.14.tgz")` | Download a MongoDB build into the current folder | N | Y | N | Y | Y | Y | N | EXTERNAL_WRITE | REMOVE (obsolete one-off) |
| 26 | `Bash(tar -xzf mongodb.tgz)` | Unpack into the current folder; can overwrite files | Y | Y | N | N | Y | Y | N | LOCAL_WRITE | REMOVE (obsolete; tarball gone) |
| 27 | `Bash(mkdir -p /tmp/mongo-test/data /tmp/mongo-test/logs)` | Create folders | N | Y | N | N | N | N | N | LOCAL_WRITE | REMOVE (obsolete) |
| 28 | `Bash(/tmp/mongo-test/mongodb-macos-aarch64-7.0.14/bin/mongod --replSet rs0 … --fork)` | Run a program **from a path in `/tmp`**, which any program on the Mac can create | N | Y | N | Y (local port) | N | N | **Y** | NEEDS_REVIEW | REMOVE. The path doesn't exist; if anything recreates it, that binary runs pre-approved |
| 29 | `Bash(cp /Users/soron/Desktop/claude-project/spin-and-win-campaign/.env.local /tmp/mongo-test/.env.local.backup *)` | See the dedicated section below | Y | Y | **Y** | N | N | Y | N | **SECRET_RISK** | **REMOVE** |
| 30 | `Bash(npm run *)` | Run **any** script in whatever `package.json` is in the current folder (dev, build, deploy, seed and so on) | Y | Y | Y | Y | (Y) | Y | **Y** | NEEDS_REVIEW | REQUIRES_EXPLICIT_APPROVAL. For example `npm run seed` writes to MongoDB, and `dev` rewrites project files |
| 31 | `Bash(disown)` | Shell job control, no effect alone | N | N | N | N | N | N | N | SAFE_READ | KEEP |
| 32 | `Bash(node /private/tmp/claude-501/…/8b7b7018…/scratchpad/test-duplicate-race.mjs)` | Run a script from an old session's scratchpad | Y | Y | Y | Y | N | Y | **Y** | NEEDS_REVIEW | REMOVE (path gone; if recreated it runs pre-approved) |
| 33 | `Bash(cp …/8b7b7018…/scratchpad/check-indexes.mjs …/verify-app/scripts/_check2.mjs)` | Copy between old scratchpad paths | Y | Y | N | N | N | Y | N | LOCAL_WRITE | REMOVE (obsolete) |
| 34 | `Bash(node scripts/_check2.mjs)` | Run a **relative-path** script, i.e. any `scripts/_check2.mjs` in the current folder | Y | Y | Y | Y | N | Y | **Y** | NEEDS_REVIEW | REMOVE (no such file exists now) |
| 35 | `Bash(rm scripts/_check2.mjs)` | Delete that relative file wherever the current folder is | N | Y | N | N | N | **Y** | N | DESTRUCTIVE | REMOVE (obsolete) |
| 36 | `Bash(pkill -f "next dev -p 3060")` | Kill matching processes | N | N | N | N | N | (Y) | N | LOCAL_WRITE | REMOVE (obsolete) |
| 37 | `Bash(pkill -f 'mongod --replSet rs0 --dbpath __TRACKED_VAR__/mongo-test/data')` | Kill matching processes. The rule contains the literal placeholder `__TRACKED_VAR__` and probably never matches | N | N | N | N | N | (Y) | N | LOCAL_WRITE | REMOVE (obsolete, likely broken) |
| 38 | `Bash(SCRATCH=/private/tmp/…/8b7b7018…/scratchpad *)` | A variable assignment **followed by anything**. As written, it matches `SCRATCH=<path> <any command>` | ? | ? | ? | ? | ? | ? | **Y?** | NEEDS_REVIEW | REMOVE. It may pre-approve any command given this prefix; whether Claude Code strips the assignment before matching is **unverified** |

## The `.env.local` rule (#29)

- **Exact pattern:** `Bash(cp /Users/soron/Desktop/claude-project/spin-and-win-campaign/.env.local /tmp/mongo-test/.env.local.backup *)`
- **Scope:** sessions rooted at `~/Desktop/claude-project`, which includes this one.
- **What it allows:**
  - Copying the Spin & Win secrets file (per `.env.example`, it holds `MONGODB_URI`, the admin username and password, and the session secret) into `/tmp`.
  - Because of the trailing ` *`, **extra arguments are allowed.** With several arguments, macOS `cp` copies every source into the **last** argument as a folder. So `cp …/.env.local /tmp/mongo-test/.env.local.backup /any/folder/` would copy the secrets file into **any folder**, all pre-approved.
- **Other risks:**
  - `/tmp` is readable by other local users and processes.
  - Rule 24 also pre-approves reading anything in `/tmp`.
  - `/tmp/mongo-test` can be created by any process.
- **Current state:** `/tmp/mongo-test` doesn't exist, so no leftover copy was found. **The rule was not run and `.env.local` was not opened.**
- **Recommendation: REMOVE.** If a backup is ever needed, do it with a one-off approval to a location Soron chooses.

## Comparison with the Clone's approval model ([[tools]])

| Clone level | Allowlist rules that fit it | Rules that contradict it (pre-approved although the Clone requires asking) |
|---|---|---|
| READ_ONLY | 03, 04, 07, 11, 14, 17, 18, 22, 31 (plus plain `npm audit`) | 01 and 24 (reads that reach secrets or personal data) |
| WRITE_APPROVAL_REQUIRED | — | 05, 06, 08, 09 (`fix`), 12, 13, 19, 20, 21, 23, 25, 26, 27, 30, 33, 36, 37 |
| DESTRUCTIVE_APPROVAL_REQUIRED | — | 10, 15, 16, 35, and 28 / 32 / 34 / 38 (arbitrary execution) |
| Standing constraints | — | 02 and 29 (secret exposure), 08 / 19 / 20 ("don't install"), 13 / 30 (can change Visionic's working tree) |

## Summary of recommendations

| Recommendation | Count | Rules |
|---|---|---|
| KEEP | 9 | 03, 04, 07, 11, 14, 17, 18, 22, 31 |
| NARROW | 2 | 09, 12 |
| REQUIRES_EXPLICIT_APPROVAL | 10 | 01, 08, 10, 13, 15, 16, 19, 20, 21, 30 |
| REMOVE | 17 | 02, 05, 06, 23, 24, 25, 26, 27, 28, 29, 32, 33, 34, 35, 36, 37, 38 |

Applying any of this changes a Claude Code config file, which needs Soron's explicit approval.

---

## Cleanup result (applied 2026-09-26, approved by Soron)

**File changed:** `~/Desktop/claude-project/.claude/settings.local.json`.
**Backup:** made before the edit, then deleted on 2026-09-26 on Soron's instruction (it still contained the removed rules).

**How "require approval" was done:** Claude Code has a separate `permissions.ask` list, which always prompts before running and takes priority over `allow`. The 9 rules moved there. No rules were deleted outright on grounds of being write-capable.

**Rule 01 (Downloads):** removed. The rule itself names no specific file, and finding one would need transcript or Downloads scanning, which isn't approved. No narrower Downloads rule was added.

| Result | Original rules |
|---|---|
| Kept in `allow`, unchanged (9) | 03, 04, 07, 11, 14, 17, 18, 22, 31 |
| Narrowed in `allow` (2 → 3 entries) | 09 → `Bash(npm audit)` + `Bash(npm audit --json)` (exact match, so `npm audit fix` is **not** allowed). 12 → `Bash(npx --no-install tsc --noEmit)` (exact) |
| Moved to `ask` (9) | 08 `npm install *`, 10 `python3 -c ' *`, 13 `npx next *`, 15 `docker rm *`, 16 `docker run *`, 19 `brew tap *`, 20 `brew install *`, 21 `brew untap *`, 30 `npm run *` |
| Removed (18) | 01, 02, 05, 06, 23–29, 32–38 |

**Final file:** 12 `allow` + 9 `ask` entries, no `deny`.

**Checked with `jq`:**
- The JSON is valid.
- All 38 original rules are accounted for. Rule 03's byte-exact match was confirmed separately.
- **None** of these remain in `allow`:
  - the `.env` copy rule, `http.server`, the `/tmp/**` or Downloads reads
  - the MongoDB rules, `_check2`, `SCRATCH=`, `pkill`, the old scratchpad paths
  - broad `python3 -c`, `docker run`/`rm`, `npm run`/`install`, `brew install`/`tap`/`untap`, `npx next`, `npm audit *`, `npx tsc *`

**Not tested** (testing would mean running the commands): how `ask` rules behave in each permission mode, including auto mode. Commands that match no rule follow the session's permission mode as before.
