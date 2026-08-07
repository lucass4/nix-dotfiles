# Claude Code configuration: context files, hand-authored skills, settings.
#
# THIS REPO IS PUBLIC. Nothing here may name an employer, a private
# marketplace, an internal wiki URL, or an unreleased model id.
#
# Split rule, same one used by ./omp.nix:
#   - Files the agent only READS are declared with `home.file` (read-only
#     /nix/store symlinks).
#   - Files the agent WRITES are bootstrapped once, then left alone. Claude
#     rewrites settings.json whenever a plugin is toggled (hence the
#     settings.json.bak it leaves behind), so a read-only symlink would break
#     `/plugin`.
#
# Deliberately NOT captured here:
#   - `settings.local.json` — machine-local overrides naming a private
#     inference gateway.
#   - `skills/myindex` — embeds internal wiki URLs.
#   - Skills symlinked out of a separate private marketplace checkout
#     (create-argocd-app, create-atlantis-app, onboard-team, frontend-slides,
#     karpathy-guidelines). They are already versioned in that repo; copying
#     them here would both duplicate and leak.
#   - `plugins/` — 61 MB of marketplace checkouts. Reproduced instead from
#     `enabledPlugins` + `extraKnownMarketplaces` in settings.json below.
#   - `projects/`, `history.jsonl`, `.credentials.json`, and the various
#     caches: credentials and transcripts of real work. Never commit these.
{ config, lib, ... }:
let
  claudeDir = "${config.home.homeDirectory}/.claude";
in
{
  # Pure inputs: Claude reads these and never writes them.
  home.file = {
    # CLAUDE.md is a one-line `@RTK.md` import; the expansion lives in RTK.md.
    ".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
    ".claude/RTK.md".source = ./claude/RTK.md;

    # Hand-authored skills. Everything else under ~/.claude/skills is a
    # symlink into a plugin cache or the private marketplace checkout.
    ".claude/skills/humanizer/SKILL.md".source = ./claude/skills/humanizer/SKILL.md;
    ".claude/skills/pr/SKILL.md".source = ./claude/skills/pr/SKILL.md;
  };

  # settings.json carries permissions, hooks, the statusline, attribution
  # suppression, and the plugin/marketplace list. Claude writes to it, so it is
  # seeded only when absent rather than symlinked. Delete the file and re-run
  # `just switch` to reset it to the version in this repo.
  #
  # Any private marketplace or plugin belongs in ~/.claude/settings.local.json,
  # which Claude merges over this file and which is intentionally unversioned.
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${claudeDir}/settings.json" ]; then
      $DRY_RUN_CMD mkdir -p "${claudeDir}"
      $DRY_RUN_CMD cp $VERBOSE_ARG ${./claude/settings.json} "${claudeDir}/settings.json"
      $DRY_RUN_CMD chmod $VERBOSE_ARG u+w "${claudeDir}/settings.json"
    fi
  '';
}
