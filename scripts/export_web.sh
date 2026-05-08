#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT/deploy/web"
TMP_DIR="$ROOT/.export/web"

mkdir -p "$TMP_DIR" "$OUT_DIR"

if ! command -v godot >/dev/null 2>&1; then
  echo "godot command not found. Install Godot 4.6 and retry." >&2
  exit 1
fi

godot --headless --path "$ROOT" --export-release "Web" "$TMP_DIR/index.html"

rsync -a --delete "$TMP_DIR/" "$OUT_DIR/"

echo "Export copied to $OUT_DIR"
