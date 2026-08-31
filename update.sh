#!/bin/sh
# Pull the latest skills and reinstall them. Idempotent; run any time.
#
#   ./update.sh                Update the global install.
#   ./update.sh --repo [p]     Update a repo-scoped install (same flags as install.sh).
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
git -C "$SRC" pull --ff-only
exec "$SRC/install.sh" "$@"
