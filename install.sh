#!/bin/bash
set -e

QS_DIR="$HOME/.config/quickshell"
REPO_URL="https://github.com/Brextal/quickshell-barra.git"

echo "=== Quickshell Setup ==="

for cmd in qs cava mpv sensors; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[WARN] '$cmd' not found. Install it before using."
    fi
done

if ! find /usr -name "mpris.so" 2>/dev/null | grep -q mpv; then
    echo "[WARN] mpv-mpris plugin not found. Music controls won't work without it."
fi

if [ -d "$QS_DIR/.git" ]; then
    echo "[SKIP] $QS_DIR already exists"
else
    echo "[CLONE] $REPO_URL -> $QS_DIR"
    git clone "$REPO_URL" "$QS_DIR"
fi

echo ""
echo "=== Done ==="
echo "Add to your hyprland.conf:"
echo "  source = ~/.config/quickshell/barra/hypr/barra.conf"
echo "  source = ~/.config/quickshell/barra/hypr/lookandfeel.conf"
echo "  source = ~/.config/quickshell/calendar/hypr/calendar.conf"
