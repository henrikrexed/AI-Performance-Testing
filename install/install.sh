#!/bin/sh
# One-step binary onboarding for AI-Performance-Testing (workload-engine).
#
#   curl -fsSL https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.sh | sh
#
# Fetches the workload-engine binary + skills bundle for the detected platform
# from a GitHub Release (checksum-verified against SHA256SUMS), unpacks into
# ~/.knightload/, installs the skills into your coding agent via
# `workload-engine init --from …`, and prints the quickstart. No repo clone,
# no Python toolchain, no root.
#
# Env overrides:
#   KNIGHTLOAD_VERSION  release tag to install (default: latest)
#   KNIGHTLOAD_DIR      install dir (default ~/.knightload)
#   KNIGHTLOAD_DEST     skills destination, passed to `init --dest`
#                       (default: engine default, ~/.claude/skills)
set -eu

REPO="henrikrexed/AI-Performance-Testing"
ENGINE="workload-engine"
DIR="${KNIGHTLOAD_DIR:-$HOME/.knightload}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "install.sh: '$1' is required" >&2; exit 1; }; }
need curl
need tar
if command -v sha256sum >/dev/null 2>&1; then SHA="sha256sum"; else SHA="shasum -a 256"; fi

case "$(uname -s)/$(uname -m)" in
  Linux/x86_64)  PLATFORM="linux-amd64" ;;
  Linux/aarch64) PLATFORM="linux-arm64" ;;
  Darwin/arm64)  PLATFORM="darwin-arm64" ;;
  Darwin/x86_64) PLATFORM="darwin-amd64" ;;
  *) echo "install.sh: unsupported platform $(uname -s)/$(uname -m)" >&2; exit 1 ;;
esac

if [ -n "${KNIGHTLOAD_VERSION:-}" ]; then
  VERSION="$KNIGHTLOAD_VERSION"
else
  VERSION="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
  [ -n "$VERSION" ] || { echo "install.sh: could not resolve the latest release" >&2; exit 1; }
fi
VER="${VERSION#v}"

BASE="https://github.com/$REPO/releases/download/$VERSION"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> $ENGINE $VERSION ($PLATFORM) -> $DIR"

curl -fsSL -o "$TMP/SHA256SUMS"                "$BASE/SHA256SUMS"
curl -fsSL -o "$TMP/$ENGINE-$PLATFORM"         "$BASE/$ENGINE-$PLATFORM"
curl -fsSL -o "$TMP/skills.tar.gz"             "$BASE/$ENGINE-skills-$VER.tar.gz"

# verify before executing anything
(cd "$TMP" && grep -E " ($ENGINE-$PLATFORM|$ENGINE-skills-$VER\.tar\.gz)$" SHA256SUMS | $SHA -c -)

BIN="$DIR/bin/$ENGINE-$VERSION"
mkdir -p "$DIR/bin"
mv "$TMP/$ENGINE-$PLATFORM" "$BIN"
chmod +x "$BIN"

rm -rf "$DIR/skills"
mkdir -p "$DIR/skills"
tar xzf "$TMP/skills.tar.gz" -C "$DIR/skills" --strip-components=1

echo "==> installing skills into your coding agent ($ENGINE init)"
INIT_ARGS="--from $DIR/skills"
if [ -n "${KNIGHTLOAD_DEST:-}" ]; then
  INIT_ARGS="$INIT_ARGS --dest $KNIGHTLOAD_DEST"
fi
# shellcheck disable=SC2086
"$BIN" init $INIT_ARGS

echo ""
echo "Installed:"
echo "  engine : $BIN"
echo "  skills : $DIR/skills"
echo ""
echo "Quickstart:"
echo "  $BIN --extract <extract.json> --out out --mode agentic"
echo "  $BIN guided --extract <extract.json> --out out --mode agentic --yes"
echo "  (guided drives propose -> choose -> generate -> try; add --try for a k6 smoke)"
