#!/usr/bin/env bash
# Give omp its own copy of the Claude Code plugin set.
#
# omp discovers ~/.claude as a fallback, so these plugins already work while
# Claude Code is installed. Installing them natively removes that dependency.
# Skills dedup by name with native (100) > omp-plugins (90) > claude (80), so
# running this is additive: no duplicates, no shadowing surprises.
#
# Idempotent — safe to re-run. Nothing here may reference a private
# marketplace; this file lives in a public repo.
set -euo pipefail

MARKETPLACES=(
  anthropics/claude-plugins-official
  https://github.com/heathdutton/claude-d2-diagrams.git
  DietrichGebert/ponytail
  JuliusBrussee/caveman
  nextlevelbuilder/ui-ux-pro-max-skill
)

PLUGINS=(
  gopls-lsp@claude-plugins-official
  superpowers@claude-plugins-official
  typescript-lsp@claude-plugins-official
  context7@claude-plugins-official
  slack@claude-plugins-official
  datadog@claude-plugins-official
  d2@claude-d2-diagrams
  ponytail@ponytail
  caveman@caveman
  ui-ux-pro-max@ui-ux-pro-max-skill
)

# antonbabenko/terraform-skill dropped its .claude-plugin/marketplace.json in
# favour of .codex-plugin, so omp can no longer add it as a marketplace. Its
# skill is installed straight into the native skills root instead.
TERRAFORM_SKILL_REPO="https://github.com/antonbabenko/terraform-skill.git"
SKILLS_ROOT="${HOME}/.omp/agent/skills"

log() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

command -v omp >/dev/null || { echo "omp not on PATH" >&2; exit 1; }

log "Adding marketplaces"
existing=$(omp plugin marketplace list 2>/dev/null || true)
for m in "${MARKETPLACES[@]}"; do
  if grep -qF "$m" <<<"$existing"; then
    printf '    skip  %s\n' "$m"
  else
    omp plugin marketplace add "$m" >/dev/null && printf '    add   %s\n' "$m"
  fi
done

log "Installing plugins"
installed=$(omp plugin list 2>/dev/null || true)
for p in "${PLUGINS[@]}"; do
  if grep -qF "$p" <<<"$installed"; then
    printf '    skip  %s\n' "$p"
  else
    omp plugin install "$p" >/dev/null && printf '    add   %s\n' "$p"
  fi
done

log "Installing terraform-skill natively"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git clone -q --depth 1 "$TERRAFORM_SKILL_REPO" "$tmp"
mkdir -p "$SKILLS_ROOT"
rm -rf "${SKILLS_ROOT:?}/terraform-skill"
cp -R "$tmp/skills/terraform-skill" "$SKILLS_ROOT/terraform-skill"
printf '    ok    terraform-skill @ %s\n' "$(git -C "$tmp" rev-parse --short HEAD)"

log "Done. Run /reload-plugins in a live session, or restart omp."
