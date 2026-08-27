#!/usr/bin/env bash
# Install the repository-convention layer.
#
#   ./install.sh                        Global (default): always-on policy + skills for every
#                                       supported agent on this machine; every repository you
#                                       open gets bootstrapped automatically.
#   ./install.sh --repo [path]          Repo-scoped: install the layer into one repository only
#                                       (default: current directory). Everything it creates is
#                                       added to a managed .gitignore section by default, so
#                                       the layer stays local to this machine.
#   ./install.sh --repo [path] --shared Repo-scoped, opted out of .gitignore: the layer is left
#                                       to be committed so collaborators get it too.
#
# Idempotent: only writes inside the managed repo-conventions blocks and
# preserves everything else in existing files.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"

HTML_BEGIN='<!-- repo-conventions:begin v2 -->'
HTML_END='<!-- repo-conventions:end -->'
HASH_BEGIN='# repo-conventions:begin v2'
HASH_END='# repo-conventions:end'

# write_block <target> <body-file> [<begin> <end>]
write_block() {
  local target="$1" body="$2" begin="${3:-$HTML_BEGIN}" end="${4:-$HTML_END}" tmp
  mkdir -p "$(dirname "$target")"
  tmp="$target.tmp"
  if [ -f "$target" ] && grep -q 'repo-conventions:begin' "$target"; then
    awk -v begin="$begin" -v end="$end" -v bodyfile="$body" '
      BEGIN { while ((getline line < bodyfile) > 0) b = b line "\n" }
      index($0, "repo-conventions:begin") { print begin; printf "%s", b; print end; skip = 1; next }
      index($0, "repo-conventions:end") && skip { skip = 0; next }
      !skip { print }
    ' "$target" > "$tmp"
  else
    {
      if [ -f "$target" ]; then cat "$target"; printf '\n'; fi
      printf '%s\n' "$begin"
      cat "$body"
      printf '%s\n' "$end"
    } > "$tmp"
  fi
  mv "$tmp" "$target"
  echo "Updated $target"
}

# remove_block <target> - strip the managed section, keeping everything else
remove_block() {
  local target="$1" tmp
  [ -f "$target" ] || return 0
  grep -q 'repo-conventions:begin' "$target" || return 0
  tmp="$target.tmp"
  awk '
    index($0, "repo-conventions:begin") { skip = 1; next }
    index($0, "repo-conventions:end") && skip { skip = 0; next }
    !skip { print }
  ' "$target" > "$tmp"
  mv "$tmp" "$target"
  echo "Removed managed section from $target"
}

# install_skills <target-dir>
install_skills() {
  local target="$1" skill
  mkdir -p "$target"
  for skill in repo-conventions-bootstrap repo-conventions-curator; do
    rm -rf "${target:?}/$skill"
    cp -r "$SRC/.github/skills/$skill" "$target/"
  done
  echo "Installed skills into $target"
}

# is_ours <file> - true when the file consists only of a managed block (safe to gitignore)
is_ours() {
  local f="$1"
  [ -f "$f" ] || return 1
  grep -q 'repo-conventions:begin' "$f" || return 1
  awk '
    index($0, "repo-conventions:begin") { skip = 1; next }
    index($0, "repo-conventions:end") && skip { skip = 0; next }
    !skip { if ($0 !~ /^[[:space:]]*$/) exit 1 }
  ' "$f"
}

install_global() {
  local body="$SRC/global/agent-policy.md"
  write_block "$HOME/.copilot/copilot-instructions.md" "$body"  # GitHub Copilot CLI
  write_block "$HOME/.claude/CLAUDE.md" "$body"                 # Claude Code
  write_block "$HOME/.codex/AGENTS.md" "$body"                  # OpenAI Codex
  write_block "$HOME/.gemini/GEMINI.md" "$body"                 # Gemini CLI
  install_skills "$HOME/.copilot/skills"
  install_skills "$HOME/.claude/skills"
  install_skills "$HOME/.agent-conventions/skills"              # neutral copy any agent can be pointed at
  echo "Global install complete. Start a new agent session to pick it up."
}

install_repo() {
  local repo="$1" shared="$2"
  [ -d "$repo" ] || { echo "No such directory: $repo" >&2; exit 1; }
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  install_skills "$repo/.github/skills"
  install_skills "$repo/.claude/skills"

  # Seed AGENTS.md only when it has no managed block yet; an agent completes
  # the bootstrap from repository evidence on the first session.
  if ! { [ -f "$repo/AGENTS.md" ] && grep -q 'repo-conventions:begin' "$repo/AGENTS.md"; }; then
    cat > "$tmpdir/seed.md" <<'SEED'
# Repository conventions

> Managed by the repo-conventions skills. Not bootstrapped yet: run the `repo-conventions-bootstrap` skill (or follow `.github/skills/repo-conventions-bootstrap/SKILL.md`) to fill this block from repository evidence.
SEED
    write_block "$repo/AGENTS.md" "$tmpdir/seed.md"
  fi

  cat > "$tmpdir/claude.md" <<'SHIM'
@AGENTS.md

If `AGENTS.md` has no completed managed `repo-conventions` block, run the `repo-conventions-bootstrap` skill before other work.
SHIM
  write_block "$repo/CLAUDE.md" "$tmpdir/claude.md"

  cat > "$tmpdir/copilot.md" <<'SHIM'
Read and follow the repository policy in `AGENTS.md` at the repository root before any work; it is required context for the whole conversation. If it has no completed managed `repo-conventions` block, run the `repo-conventions-bootstrap` skill first.
SHIM
  write_block "$repo/.github/copilot-instructions.md" "$tmpdir/copilot.md"

  if [ "$shared" = "1" ]; then
    remove_block "$repo/.gitignore"
    echo "Repo-scoped install complete in $repo (shared). Commit the new files to share the layer."
  else
    # Ignore only files the layer owns outright; files carrying user content stay tracked.
    {
      echo "# Convention layer, local to this machine by default; rerun with --shared to commit it"
      echo ".github/skills/repo-conventions-bootstrap/"
      echo ".github/skills/repo-conventions-curator/"
      echo ".claude/skills/repo-conventions-bootstrap/"
      echo ".claude/skills/repo-conventions-curator/"
      if is_ours "$repo/AGENTS.md"; then echo "AGENTS.md"; fi
      if is_ours "$repo/CLAUDE.md"; then echo "CLAUDE.md"; fi
      if is_ours "$repo/.github/copilot-instructions.md"; then echo ".github/copilot-instructions.md"; fi
    } > "$tmpdir/ignore"
    write_block "$repo/.gitignore" "$tmpdir/ignore" "$HASH_BEGIN" "$HASH_END"
    echo "Repo-scoped install complete in $repo. The layer is gitignored; rerun with --shared to commit it."
  fi
}

MODE=global
REPO="$PWD"
SHARED=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      MODE=repo
      shift
      if [ $# -gt 0 ] && [ "${1#--}" = "$1" ]; then REPO="$1"; shift; fi
      ;;
    --shared) SHARED=1; shift ;;
    *) echo "usage: $0 [--repo [path]] [--shared]" >&2; exit 1 ;;
  esac
done

if [ "$MODE" = "global" ]; then
  install_global
else
  install_repo "$REPO" "$SHARED"
fi
