#!/usr/bin/env bash

set -euo pipefail

BAT_DIR=/sys/class/power_supply/BAT0
AC_DIR=/sys/class/power_supply/AC0

usage() {
  cat <<'EOF'
usage: power [command]

commands:
  status          show cpu, gpu, ac and battery status (default)
  battery         show battery status

gpu (g|gpu-mode):
  hybrid          switch the dGPU to Hybrid mode
  integrated      switch the dGPU to Integrated mode
  get             show the current dGPU mode

cpu (c|cpu-profile):
  save            switch to the power-saver profile
  balanced        switch to the balanced profile
  perf            switch to the performance profile
  get             show the current power profile

planned: charge, fans, doctor, logs

full manual: man power
EOF
}

battery() {
  if [ ! -d "$BAT_DIR" ]; then
    printf '%s\n' 'battery: none'
    return
  fi
  local percent status
  percent=$(cat "$BAT_DIR/capacity" 2>/dev/null || printf '?')
  status=$(cat "$BAT_DIR/status" 2>/dev/null || printf 'Unknown')
  printf 'battery:    %s (%s%%)\n' "$status" "$percent"
}

status() {
  printf 'cpu:        %s\n' "$(powerprofilesctl get)"
  printf 'gpu:        %s\n' "$(supergfxctl -g)"
  if [ -d "$AC_DIR" ]; then
    case "$(cat "$AC_DIR/online" 2>/dev/null || printf '0')" in
      1) printf '%s\n' 'ac:         connected' ;;
      *) printf '%s\n' 'ac:         on battery' ;;
    esac
  fi
  battery
}

gpu_group() {
  case "${1:-}" in
    hybrid)
      supergfxctl -m Hybrid
      ;;
    integrated)
      supergfxctl -m Integrated
      ;;
    get)
      supergfxctl -g
      ;;
    '')
      printf 'power: gpu: missing mode (hybrid|integrated|get)\n' >&2
      exit 1
      ;;
    *)
      printf 'power: gpu: unknown mode %s\n' "$1" >&2
      exit 1
      ;;
  esac
}

cpu_group() {
  case "${1:-}" in
    save)
      powerprofilesctl set power-saver
      ;;
    balanced)
      powerprofilesctl set balanced
      ;;
    perf)
      powerprofilesctl set performance
      ;;
    get)
      powerprofilesctl get
      ;;
    '')
      printf 'power: cpu: missing profile (save|balanced|perf|get)\n' >&2
      exit 1
      ;;
    *)
      printf 'power: cpu: unknown profile %s\n' "$1" >&2
      exit 1
      ;;
  esac
}

cmd="${1:-status}"

case "$cmd" in
  status)
    status
    ;;
  battery)
    battery
    ;;
  g | gpu | gpu-mode)
    gpu_group "${2:-}"
    ;;
  c | cpu | cpu-profile)
    cpu_group "${2:-}"
    ;;
  help | -h | --help)
    usage
    ;;
  charge | fans | doctor | logs)
    printf 'power: %s is not implemented yet\n' "$cmd" >&2
    exit 1
    ;;
  *)
    printf 'power: unknown command %s\n' "$cmd" >&2
    usage >&2
    exit 1
    ;;
esac
