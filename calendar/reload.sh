#!/bin/bash
pkill -f "qs .*calendar/shell.qml" 2>/dev/null
sleep 0.3
nohup qs -p "$(cd "$(dirname "$0")" && pwd)/shell.qml" >/dev/null 2>&1 &
disown
