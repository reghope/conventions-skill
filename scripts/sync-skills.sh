#!/usr/bin/env bash
# Mirror the canonical skills (.github/skills) into .claude/skills.
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf .claude/skills
mkdir -p .claude
cp -r .github/skills .claude/skills
echo "Synced .github/skills -> .claude/skills"
