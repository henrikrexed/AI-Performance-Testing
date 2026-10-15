#!/bin/sh
# One-command install for AI-Performance-Testing (repo-root entrypoint).
#
#   curl -fsSL https://raw.githubusercontent.com/henrikrexed/AI-Performance-Testing/main/install.sh | sh
#
# Delegates to the release installer, which fetches the workload-engine binary
# + skills bundle for your platform (checksum-verified against SHA256SUMS),
# installs the skills into your coding agent (`workload-engine init`), runs the
# dependency pre-flight, and prints the quickstart. No git, no clone, no root.
#
# Env overrides (passed through to the release installer):
#   KNIGHTLOAD_VERSION  release tag to install (default: latest)
#   KNIGHTLOAD_DIR      install dir (default ~/.knightload)
#   KNIGHTLOAD_DEST     skills destination, passed to `init --dest`
#                       (default: engine default, ~/.claude/skills)
#
# Contributors: to hack on the repo itself, clone it — see README.md
# ("Contributors"). This entrypoint is the user install path.
set -eu

REPO="henrikrexed/AI-Performance-Testing"
URL="https://github.com/$REPO/releases/latest/download/install.sh"

if ! command -v curl >/dev/null 2>&1; then
  if command -v wget >/dev/null 2>&1; then
    echo "==> delegating to the release installer"
    wget -qO- "$URL" | sh
    exit
  fi
  echo "install.sh: curl (or wget) is required to fetch the release installer:" >&2
  echo "  $URL" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "==> delegating to the release installer"
curl -fsSL "$URL" -o "$TMP/install.sh"
sh "$TMP/install.sh"
