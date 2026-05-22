#!/usr/bin/env bash
# Install the agent-security-review skill into ~/.claude/skills/ (standalone, no plugin needed).
#
#   curl -fsSL https://raw.githubusercontent.com/raxITlabs/agent-security-review/main/install.sh | bash
#
# Optional: pass a branch, tag, or commit SHA to pin a version:
#   curl -fsSL .../install.sh | bash -s -- v0.1.0
set -euo pipefail

REPO="raxITlabs/agent-security-review"
REF="${1:-main}"
SRC_SUBDIR="skills/agent-security-review"
DEST="$HOME/.claude/skills/agent-security-review"

echo "Installing agent-security-review skill from ${REPO}@${REF} ..."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# One request, no git dependency; --strip-components drops the top repo dir.
curl -fsSL "https://codeload.github.com/${REPO}/tar.gz/${REF}" | tar -xz -C "$tmp" --strip-components=1

src="${tmp}/${SRC_SUBDIR}"
if [ ! -f "${src}/SKILL.md" ]; then
  echo "error: SKILL.md not found in the downloaded archive (${SRC_SUBDIR})" >&2
  exit 1
fi

mkdir -p "$DEST"
# Copy the skill (SKILL.md + scripts/ + references/), excluding any local runtime cache.
( cd "$src" && tar --exclude='./.cache' -cf - . ) | tar -xf - -C "$DEST"

echo "Installed to ${DEST}"
echo
echo "ast-grep is required to run scans. If you don't have it:"
echo "  brew install ast-grep   |   npm i -g @ast-grep/cli   |   pip install ast-grep-cli"
echo
echo "Then in Claude Code, just ask: \"security-review my agent code\" (or /agent-security-review)."
