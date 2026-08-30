#!/usr/bin/env bash
# Mirror the canonical skills (skills/<category>/) into the agent-facing
# directories: .claude/skills and .github/skills (flattened, no category).
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf .claude/skills .github/skills
mkdir -p .claude/skills .github/skills
for skill in skills/*/*/; do
  name="$(basename "$skill")"
  cp -r "$skill" ".claude/skills/$name"
  cp -r "$skill" ".github/skills/$name"
done
echo "Synced skills/*/* -> .claude/skills and .github/skills"
