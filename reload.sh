#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
pkill -f "qs .*barra/shell.qml" 2>/dev/null || true
sleep 0.1
exec qs -p "$SCRIPT_DIR/shell.qml"
