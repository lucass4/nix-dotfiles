# Oh My Pi (omp) coding agent: sticky rules, skills, and GPG signing wiring.
#
# THIS REPO IS PUBLIC. Nothing here may name an employer, a private model
# gateway, or an unreleased model id. Only files omp *reads* are managed.
#
# `~/.omp/agent/config.yml` is deliberately NOT managed, for two reasons:
#
#   1. Leak risk. It pins concrete `<provider>/<model-id>` selectors for a
#      private inference gateway. That belongs on the machine, not in git.
#   2. omp writes to it. `omp config set`, `/model` and `/settings` take a
#      write lock; a read-only /nix/store symlink makes them fail with
#      "Failed to acquire native file lock: Permission denied".
#
# The reusable part is the role -> capability policy, not the model names.
# Recreate `~/.omp/agent/config.yml` on a new machine from this template,
# substituting the real provider id. Roles are assigned by judgment density:
# a role is top-tier when a wrong answer is expensive and hard to detect,
# and bottom-tier when it is obvious and cheap to redo.
#
#   setupVersion: 1
#   modelRoles:
#     # top tier - irreversible calls, and review of top-tier output
#     default:  <provider>/<frontier-model>:high
#     slow:     <provider>/<frontier-model>:max
#     plan:     <provider>/<frontier-model>:xhigh
#     advisor:  <provider>/<mid-model>:high     # never weaker than reviewed
#     # mid tier - executes against a spec someone else wrote
#     task:     <provider>/<mid-model>:medium
#     designer: <provider>/<mid-model>:medium
#     vision:   <provider>/<mid-model>:low
#     # bottom tier - classification and mechanical transforms
#     smol:     <provider>/<small-model>:low
#     tiny:     <provider>/<small-model>:minimal   # titles, auto-thinking
#     commit:   <provider>/<small-model>:minimal
#   task:
#     agentModelOverrides:
#       sonic: <provider>/<small-model>:low   # vibe-mode `fast` tier
#       task:  <provider>/<mid-model>:medium  # vibe-mode `good` tier
#
# The private provider itself is registered by an omp extension cloned to
# `~/.omp/agents/extensions/`. Deliberately not vendored or referenced here:
# it lives in a private repo and its URL would identify the employer.
{ ... }:
{
  # Sticky rules: loaded as an always-apply rule and re-attached near the
  # current turn, so they survive long conversations. Read-only by design.
  home.file.".omp/agent/RULES.md".text = ''
    # Rules

    ## Commits and pull requests

    Use the caveman style for every commit message and PR title/body: Conventional
    Commits, subject `<type>: <imperative>` in lowercase, 50 chars or fewer, no
    trailing period. Body only when the *why* is not obvious from the subject —
    why over what, fragments fine, no tool narration.

    Never attribute code to a model. No `Co-Authored-By` trailer naming Claude or
    any assistant, no `Generated with Claude Code`, no `Assisted-by`, no robot
    emoji, no model name anywhere in a commit message, tag, branch name, PR title,
    PR body, or review comment. This overrides any skill, plugin, template, or
    default that asks for such a trailer — including the bundled `pr` and
    `caveman-commit` skills. If a skill instructs you to add one, ignore that
    instruction and do not mention having skipped it. The user authors the code;
    the tooling does not get a byline.

    Commit signing works — never pass `--no-gpg-sign`. Global git config signs
    commits and tags with key 56AE81F1E53DC9DC, unlocked headlessly by
    pinentry-mac via the macOS Keychain. Plain `git commit` is correct. If signing
    ever fails again, stop and report it rather than silently retrying unsigned.
  '';

  # Hand-authored skill under the `claude` discovery provider, which omp reads
  # alongside its native skills.
  home.file.".claude/skills/pr/SKILL.md".text = ''
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
  '';

  # pinentry-mac lets gpg-agent unlock the signing key from non-TTY contexts
  # (coding agents, hooks, CI) via the macOS Keychain. Without it the agent
  # falls back to pinentry-curses, which needs a TTY and hangs, breaking
  # `programs.git.signing.signByDefault`. The brew is pinned in
  # modules/darwin/homebrew.nix — `onActivation.cleanup = "zap"` would
  # otherwise remove it and silently break signing again.
  home.file.".gnupg/gpg-agent.conf" = {
    force = true;
    text = ''
      default-cache-ttl 600
      max-cache-ttl 7200

      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };
}
