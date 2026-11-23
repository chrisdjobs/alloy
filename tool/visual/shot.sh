#!/usr/bin/env bash
# Screenshot the app running on the Android emulator.
#
#   tool/visual/shot.sh <name>   writes build/screenshots/<name>.png
#   tool/visual/shot.sh reset    restores the default display metrics
#
# Visual review is Android in portrait only; there is no wide preset.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SERIAL="${SERIAL:-emulator-5554}"
OUT="$ROOT/build/screenshots"

usage() {
  sed -n '2,7p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

if ! adb devices | awk 'NR > 1 { print $1 }' | grep -qx "$SERIAL"; then
  echo "device $SERIAL is not connected; run tool/visual/loop.sh start" >&2
  exit 1
fi

if [[ "${1:-}" == "reset" ]]; then
  adb -s "$SERIAL" shell wm size reset >/dev/null
  adb -s "$SERIAL" shell wm density reset >/dev/null
  echo "display metrics reset"
  exit 0
fi

if [[ $# -ne 1 || -z "$1" ]]; then
  usage
  exit 1
fi

mkdir -p "$OUT"
adb -s "$SERIAL" exec-out screencap -p >"$OUT/$1.png"
echo "$OUT/$1.png"
