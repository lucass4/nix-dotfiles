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
