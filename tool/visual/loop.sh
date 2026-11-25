#!/usr/bin/env bash
# Keep one flutter run session alive for visual work.
#
#   tool/visual/loop.sh start|stop|reload|restart|status
#
# start boots the AVD when the device is missing, launches flutter run detached
# with a pid file, and waits until the app is installed. reload is a hot
# reload (SIGUSR1), restart a hot restart (SIGUSR2).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export PATH="$HOME/flutter/bin:$PATH"

SERIAL="${SERIAL:-emulator-5554}"
AVD="${AVD:-Pixel_10_Pro}"
PIDFILE="${PIDFILE:-/tmp/opencode/alloy.pid}"
LOG="${LOG:-/tmp/opencode/alloy-flutter-run.log}"

device_ready() {
  adb devices | awk 'NR > 1 { print $1 }' | grep -qx "$SERIAL"
}

boot_device() {
  device_ready && return 0
  echo "booting $AVD..."
  flutter emulators --launch "$AVD" >/dev/null
  for _ in $(seq 1 120); do
    device_ready && break
    sleep 2
  done
  if ! device_ready; then
    echo "$SERIAL never appeared; check $AVD" >&2
    exit 1
  fi
  adb -s "$SERIAL" wait-for-device
  for _ in $(seq 1 60); do
    if [[ "$(adb -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == 1 ]]; then
      return 0
    fi
    sleep 2
  done
  echo "$SERIAL did not finish booting" >&2
  exit 1
}

running_pid() {
  [[ -f "$PIDFILE" ]] || return 1
  local pid
  pid="$(cat "$PIDFILE")"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null && echo "$pid"
}

start() {
  local pid
  if pid="$(running_pid)"; then
    echo "already running (pid $pid)"
    return 0
  fi
  boot_device
  mkdir -p "$(dirname "$PIDFILE")" "$(dirname "$LOG")"
  : >"$LOG"
  cd "$ROOT"
  nohup setsid flutter run \
    -d "$SERIAL" \
    --pid-file "$PIDFILE" \
    --no-devtools >"$LOG" 2>&1 </dev/null &
  echo "starting flutter run; log: $LOG"
  for _ in $(seq 1 180); do
    if grep -qE "Dart VM Service|Syncing files to device|Flutter run key commands" "$LOG" 2>/dev/null; then
      echo "attached to $SERIAL"
      return 0
    fi
    if grep -qiE "^(Error|Exception):|Failed to|Lost connection" "$LOG" 2>/dev/null; then
      echo "flutter run failed:" >&2
      tail -20 "$LOG" >&2
      exit 1
    fi
    sleep 2
  done
  echo "timed out waiting for flutter run; see $LOG" >&2
  tail -20 "$LOG" >&2
  exit 1
}

stop() {
  local pid
  if ! pid="$(running_pid)"; then
    rm -f "$PIDFILE"
    echo "not running"
    return 0
  fi
  kill "$pid" 2>/dev/null || true
  for _ in $(seq 1 15); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 1
  done
  kill -0 "$pid" 2>/dev/null && kill -9 "$pid"
  rm -f "$PIDFILE"
  echo "stopped (pid $pid)"
}

signal_run() {
  local pid
  if ! pid="$(running_pid)"; then
    echo "not running; start it with tool/visual/loop.sh start" >&2
    exit 1
  fi
  kill "-$1" "$pid"
  echo "sent SIG$1 to $pid"
}

case "${1:-}" in
  start) start ;;
  stop) stop ;;
  reload) signal_run USR1 ;;
  restart) signal_run USR2 ;;
  status)
    if pid="$(running_pid)"; then
      echo "flutter run alive (pid $pid), log: $LOG"
    else
      echo "flutter run not running"
    fi
    if device_ready; then echo "device $SERIAL connected"; else echo "device $SERIAL missing"; fi
    ;;
  *)
    sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
