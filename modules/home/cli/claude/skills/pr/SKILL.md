---
name: pr
description: >
  Commit the current changes and open a GitHub PR in one shot. Writes a
  caveman-terse Conventional Commits message (why over what), branches off the
  default branch if needed, pushes, and runs `gh pr create`. Use when the user
  says "PR", "/pr", "ship it", "commit and open a PR", or "make a pull request".
---

# pr — commit + open PR in one shot

Goal: from a dirty working tree to a pushed PR with one invocation. Terse
Conventional Commits message, minimal ceremony.

## Steps

1. **Read the change.** `git status --short` and `git diff` (staged + unstaged).

2. **Existing PR? Push to it, don't make a new one.** Check the current branch
   for an open PR: `gh pr view --json url,state -q .url` (empty/errors = none).
   If one exists **and is OPEN**, this is the common case — stay on this branch,
   do NOT create a new branch, do NOT run `gh pr create`. Just commit (step 4-5)
   and push (step 6); the push updates the PR. Then report its URL and stop.
   Nothing new to commit and the PR is already up to date? Say so, stop.

3. **Branch (only when no open PR yet).** `git branch --show-current`. If on the
   default branch (`main`/`master`), create a topic branch first — never PR from
   default. Name it `<type>/<short-slug>` from the change (e.g. `feat/helm-scan`,
   `fix/token-expiry`). Otherwise reuse the current branch.

3b. **Stage.** `git add -A` (unless the user staged a deliberate subset — then
   respect it).

4. **Write the message** — Conventional Commits, caveman-terse:
   - Subject: `<type>: <imperative>`, ≤50 chars, lowercase after type, no period.
     Types: feat, fix, refactor, docs, test, chore, perf, build, ci.
   - Body: only when *why* isn't obvious from the subject. Why over what. Wrap
     ~72 cols. Drop articles/filler; fragments fine. No tool narration.
   - Multiple unrelated concerns? Prefer splitting into separate commits when
     files separate cleanly; don't hunk-surgeon if it needs much rework — one
     commit with a body noting the secondary change is fine.

5. **Commit.** NEVER add `Co-Authored-By`, `Generated with Claude Code`, or any
   other model/AI attribution trailer to the message. The commit is the user's.
   Commit signing works via pinentry-mac + Keychain — use plain `git commit`,
   never `--no-gpg-sign`. If signing fails, stop and report it.

6. **Push.** `git push -u origin <branch>`.

7. **Open the PR** (only if step 2 found no open PR). `gh pr create --title
   "<subject>" --body "<body>"`. Reuse the commit subject as the title and the
   commit body as the PR body. NEVER append "Generated with Claude Code" or any
   Claude/robot attribution to the PR body or title.

8. **Report** the PR URL. Done.

## Rules

- One shot: don't stop to ask for approval mid-flow unless the diff looks
  destructive or spans unrelated large changes — then confirm the split first.
- Confirm before force-push or before amending an already-pushed commit.
- Requires `gh` authenticated. If `gh auth status` fails, stop and say so.
- `--fill` is a fallback only; prefer the caveman message you wrote.
