#!/usr/bin/env bash
set -euo pipefail

REF="${1:-release}"
REPO_RAW="https://raw.githubusercontent.com/Ekith/nova/$REF"
BIN_DIR="$HOME/.local/bin"
COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"

mkdir -p "$BIN_DIR" "$COMPLETION_DIR"

echo "Installing nova ($REF) to $BIN_DIR/nova..."
curl -fsSL "$REPO_RAW/nova.sh" -o "$BIN_DIR/nova" || {
    echo "Erreur : version '$REF' introuvable." >&2
    exit 1
}
chmod +x "$BIN_DIR/nova"

echo "Installing bash completion to $COMPLETION_DIR/nova..."
curl -fsSL "$REPO_RAW/nova_completion.bash" -o "$COMPLETION_DIR/nova"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo "Warning: $BIN_DIR is not in your PATH. Add it to your shell rc file." ;;
esac

echo "nova installed. Open a new shell (or 'source' your rc file) and run: nova <command>"
