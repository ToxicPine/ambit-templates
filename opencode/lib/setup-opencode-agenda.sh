#!/bin/bash
set -euo pipefail

# Idempotent setup of opencode-agenda-plugin and opencode-agenda-skill.
# Runs as a regular user with HOME, git, bun, and jq on PATH.

OPENCODE_DIR="$HOME/.config/opencode"
MARKER="$OPENCODE_DIR/.agenda-installed"

[ -f "$MARKER" ] && exit 0

mkdir -p "$OPENCODE_DIR/commands" "$OPENCODE_DIR/skills"

# --- Clean up old scheduler plugin artifacts ---
rm -rf "$OPENCODE_DIR/plugins/scheduler" "$OPENCODE_DIR/plugins/scheduler.ts"
rm -f "$OPENCODE_DIR/.scheduler-installed"

# --- Plugin: register npm package in global config ---
CONFIG="$OPENCODE_DIR/config.json"
if [ ! -f "$CONFIG" ]; then
  printf '{"plugin":[]}\n' > "$CONFIG"
fi
if ! jq -e '.plugin // [] | index("@toxicpine/opencode-agenda-plugin")' "$CONFIG" >/dev/null 2>&1; then
  jq '.plugin = ((.plugin // []) + ["@toxicpine/opencode-agenda-plugin"])' \
    "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
fi

# --- Commands: clone repo to copy command markdown files ---
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
git clone --depth 1 https://github.com/ToxicPine/opencode-agenda-plugin.git "$tmpdir/plugin"
cp "$tmpdir/plugin"/commands/*.md "$OPENCODE_DIR/commands/"

# --- Skill: opencode-agenda-skill ---
rm -rf "$OPENCODE_DIR/skills/opencode-scheduler"
if [ ! -d "$OPENCODE_DIR/skills/opencode-agenda" ]; then
  git clone --depth 1 \
    https://github.com/ToxicPine/opencode-agenda-skill.git \
    "$OPENCODE_DIR/skills/opencode-agenda"
fi

touch "$MARKER"
