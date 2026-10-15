#!/bin/sh
# One-step binary onboarding for AI-Performance-Testing (workload-engine).
#
#   curl -fsSL https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.sh | sh
#
# Fetches the workload-engine binary + skills bundle for the detected platform
# from a GitHub Release (checksum-verified against SHA256SUMS), unpacks into
# ~/.knightload/, installs the skills into your coding agent via
# `workload-engine init --from …`, runs the install-time dependency pre-flight
# (exact fix commands for anything missing), and prints the quickstart.
# No repo clone, no root. The engine binary itself needs no Python or Node.
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
  Darwin/x86_64) PLATFORM="darwin-arm64"; INTEL_ROSETTA=1 ;;
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

[ -n "${INTEL_ROSETTA:-}" ] && \
  echo "note: Intel Mac — no darwin-amd64 build exists; installing the arm64 binary (runs via Rosetta 2)."
echo "==> $ENGINE $VERSION ($PLATFORM) -> $DIR"

curl -fsSL -o "$TMP/SHA256SUMS"                "$BASE/SHA256SUMS"
curl -fsSL -o "$TMP/$ENGINE-$PLATFORM"         "$BASE/$ENGINE-$PLATFORM"
curl -fsSL -o "$TMP/$ENGINE-skills-$VER.tar.gz" "$BASE/$ENGINE-skills-$VER.tar.gz"

# verify before executing anything
(cd "$TMP" && grep -E " ($ENGINE-$PLATFORM|$ENGINE-skills-$VER\.tar\.gz)$" SHA256SUMS | $SHA -c -)

BIN="$DIR/bin/$ENGINE-$VERSION"
mkdir -p "$DIR/bin"
mv "$TMP/$ENGINE-$PLATFORM" "$BIN"
chmod +x "$BIN"
# stable unversioned name ($DIR/bin/workload-engine) for quickstarts
ln -sf "$ENGINE-$VERSION" "$DIR/bin/$ENGINE"

# unpack: <bundle>/{skills,docs,README.md} -> $DIR/skills (the skills dir itself)
# and $DIR/docs; `init --from` requires workload-model/SKILL.md directly inside.
rm -rf "$DIR/skills" "$DIR/docs"
BUNDLE="$TMP/unpack"
mkdir -p "$BUNDLE"
tar xzf "$TMP/$ENGINE-skills-$VER.tar.gz" -C "$BUNDLE"
mv "$BUNDLE"/*/skills "$DIR/skills"
[ -d "$BUNDLE"/*/docs ] && mv "$BUNDLE"/*/docs "$DIR/docs"

echo "==> installing skills into your coding agent ($ENGINE init)"
INIT_ARGS="--from $DIR/skills"
if [ -n "${KNIGHTLOAD_DEST:-}" ]; then
  INIT_ARGS="$INIT_ARGS --dest $KNIGHTLOAD_DEST"
fi
# shellcheck disable=SC2086
"$BIN" init $INIT_ARGS

# install-time dependency pre-flight: report anything the skills need with the
# exact fix command — never a late mid-task failure. The install itself still
# succeeds; this is a health report, not a gate.
SETUP="$DIR/skills/setup.sh"
if [ -f "$SETUP" ]; then
  if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
    echo "==> skill dependency pre-flight"
    if ! sh "$SETUP"; then
      echo ""
      echo "  (pre-flight reported missing tools above — the engine and skills are"
      echo "   installed; fix the items marked MISS, then re-run:  sh $SETUP)"
    fi
  else
    echo "==> skill dependency pre-flight: SKIPPED (python not found)"
    echo "  the skills need Python >= 3.9 and Node >= 18; install them, then verify:"
    echo "    sh $SETUP"
    echo "  https://www.python.org/downloads/   https://nodejs.org/"
  fi
fi

echo ""
echo "Installed:"
echo "  engine : $DIR/bin/$ENGINE  (-> $BIN)"
echo "  skills : $DIR/skills  (installed into your agent by '$ENGINE init')"
echo ""
echo "Quickstart:"
echo "  $DIR/bin/$ENGINE --extract <extract.json> --out out --mode agentic"
echo "  $DIR/bin/$ENGINE guided --extract <extract.json> --out out --mode agentic --yes"
echo "  (guided drives propose -> choose -> generate -> try; add --try for a k6 smoke)"
echo "  example extract (no clone needed):"
echo "    curl -fsSL https://raw.githubusercontent.com/$REPO/main/examples/crewai-deepseek-agent/extract.json -o extract.json"
