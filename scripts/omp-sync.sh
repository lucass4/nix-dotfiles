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

# Destructive-command gate. Lives here rather than in a nix file because omp
# holds a write lock on config.yml.
#
# approvalMode stays `yolo` — this gates by command, not by tier, so ordinary
# work stays promptless. Rules are ordered, first match wins, and both `deny`
# and `prompt` are checked against the whole command AND each shell segment, so
# `cd /tmp && rm -rf build` is caught.
#
# Why two tiers, and why the split is where it is: a headless session (task
# subagents, `omp -p`, CI) has no UI to prompt, and silently downgrades
# `prompt` to allow — measured, not assumed. `deny` is the only tier enforced
# everywhere. So anything irreversible is `deny` and you run it yourself;
# reviewable things stay `prompt`, which does gate in the TUI.
#
# `deny` also re-arms the built-in critical-pattern guard (rm -rf /, fork
# bombs, curl|sh), which yolo otherwise ignores.
log "Applying destructive-command gate"
omp config set bash.patterns "$(cat <<'JSON'
[
  {"match":"rm -rf /","approval":"deny"},
  {"match":"rm -rf /Users","approval":"deny"},
  {"match":"rm -rf ~","approval":"deny"},
  {"match":"rm -rf $HOME","approval":"deny"},
  {"match":"rm -rf .","approval":"deny"},
  {"match":"mkfs*","approval":"deny"},
  {"match":"dd if=* of=/dev/*","approval":"deny"},
  {"match":"shutdown *","approval":"deny"},
  {"match":"reboot","approval":"deny"},
  {"match":"halt","approval":"deny"},
  {"match":"chmod -R 777 /","approval":"deny"},
  {"match":"* | sh","approval":"deny"},
  {"match":"* | bash","approval":"deny"},
  {"match":"* | sudo sh","approval":"deny"},
  {"match":"* | sudo bash","approval":"deny"},
  {"match":":(){ :|:& };:","approval":"deny"},
  {"match":"terraform destroy*","approval":"deny"},
  {"match":"tofu destroy*","approval":"deny"},
  {"match":"terragrunt destroy*","approval":"deny"},
  {"match":"terraform state rm*","approval":"deny"},
  {"match":"terraform state mv*","approval":"deny"},
  {"match":"terraform workspace delete*","approval":"deny"},
  {"match":"aws * delete-*","approval":"deny"},
  {"match":"aws * terminate-*","approval":"deny"},
  {"match":"aws s3 rb*","approval":"deny"},
  {"match":"git push --force*","approval":"deny"},
  {"match":"git push -f *","approval":"deny"},
  {"match":"terraform apply*","approval":"prompt"},
  {"match":"terraform import*","approval":"prompt"},
  {"match":"tofu apply*","approval":"prompt"},
  {"match":"terragrunt apply*","approval":"prompt"},
  {"match":"terragrunt run-all*","approval":"prompt"},
  {"match":"kubectl delete*","approval":"prompt"},
  {"match":"kubectl drain*","approval":"prompt"},
  {"match":"kubectl replace --force*","approval":"prompt"},
  {"match":"kubectl rollout undo*","approval":"prompt"},
  {"match":"kubectl scale*","approval":"prompt"},
  {"match":"helm uninstall*","approval":"prompt"},
  {"match":"helm delete*","approval":"prompt"},
  {"match":"helm rollback*","approval":"prompt"},
  {"match":"eksctl delete*","approval":"prompt"},
  {"match":"vcluster delete*","approval":"prompt"},
  {"match":"argocd app delete*","approval":"prompt"},
  {"match":"argocd app sync*","approval":"prompt"},
  {"match":"argocd app rollback*","approval":"prompt"},
  {"match":"aws * remove-*","approval":"prompt"},
  {"match":"aws s3 rm*","approval":"prompt"},
  {"match":"git reset --hard*","approval":"prompt"},
  {"match":"git clean -*d*","approval":"prompt"},
  {"match":"git branch -D*","approval":"prompt"},
  {"match":"rm -rf *","approval":"prompt"},
  {"match":"docker system prune*","approval":"prompt"},
  {"match":"docker volume rm*","approval":"prompt"}
]
JSON
)" >/dev/null
printf '    ok    %s rules\n' "$(omp config get bash.patterns | tr ',' '\n' | grep -c approval)"

log "Done. Run /reload-plugins in a live session, or restart omp."
