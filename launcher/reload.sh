#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
kill $(pgrep -f "qs .*launcher/shell.qml") 2>/dev/null
sleep 0.2
qs -p "$SCRIPT_DIR/shell.qml" &
disown
