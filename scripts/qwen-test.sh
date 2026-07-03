#!/usr/bin/env bash
# Validate qwen3-8b commit message generation against staged changes.
# Usage: ./scripts/qwen-test.sh
# Reads `git diff --staged`, generates a commit message via mlx-lm, prints to stdout.
# First run downloads ~4.5GB to ~/.cache/huggingface/.

set -euo pipefail

MODEL="${QWEN_MODEL:-mlx-community/Qwen3-8B-4bit}"
MAX_TOKENS="${QWEN_MAX_TOKENS:-200}"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: not a git repository" >&2
  exit 1
fi

if git diff --staged --quiet; then
  echo "error: no staged changes. run 'git add <files>' first." >&2
  exit 1
fi

diff="$(git diff --staged)"
diff_bytes=${#diff}
diff_lines=$(printf '%s\n' "$diff" | wc -l | tr -d ' ')

{
  echo "model:        $MODEL"
  echo "staged diff:  ${diff_lines} lines, ${diff_bytes} bytes"
  echo "max tokens:   $MAX_TOKENS"
  echo "---"
} >&2

read -r -d '' prompt <<EOF || true
Write a single conventional commit message for the git diff below.

Rules:
- Format: <type>(<scope>): <subject>
- Subject in imperative mood, under 72 characters
- Add a body only if the change is non-trivial; separate with a blank line
- Output ONLY the commit message. No preamble, no code fences, no explanation.

Diff:
$diff
EOF

# Time the generation so we can compare against pure-Claude cost.
start=$(date +%s)
uv tool run --from mlx-lm mlx_lm.generate \
  --model "$MODEL" \
  --prompt "$prompt" \
  --max-tokens "$MAX_TOKENS" \
  --temp 0.3
status=$?
end=$(date +%s)

echo "---" >&2
echo "elapsed: $((end - start))s" >&2
exit "$status"
