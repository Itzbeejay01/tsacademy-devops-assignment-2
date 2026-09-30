#!/usr/bin/env bash

# TS Academy DevOps Assignment 2
# Dockerized diagnostic command-line application.

set -u

show_help() {
  cat <<'EOF'
Usage: diagnostic <command> [arguments]

Commands:
  system              Display useful Linux system information
  network <host>      Resolve and check connectivity to a host
  disk                Display filesystem disk information
  help                Display this help message

Exit codes:
  0  success
  1  operational/runtime failure
  2  invalid command or input
EOF
}

system_info() {
  echo "========== System Information =========="
  printf 'Hostname: %s\n' "$(hostname)"
  printf 'Current user: %s\n' "$(id -un)"
  printf 'Date/Time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"

  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf 'Operating system: %s\n' "${PRETTY_NAME:-${NAME:-Linux}}"
  else
    printf 'Operating system: %s\n' "$(uname -s)"
  fi

  printf 'Kernel: %s\n' "$(uname -r)"
  printf 'Architecture: %s\n' "$(uname -m)"
  printf 'Uptime: %s\n' "$(uptime 2>/dev/null || echo unavailable)"

  if command -v nproc >/dev/null 2>&1; then
    printf 'CPU cores: %s\n' "$(nproc)"
  fi

  if command -v free >/dev/null 2>&1; then
    echo "Memory:"
    free -h
  elif [[ -r /proc/meminfo ]]; then
    echo "Memory:"
    awk '/MemTotal|MemAvailable/ {print "  " $1 " " $2 " " $3}' /proc/meminfo
  fi

  echo "========================================"
}

network_check() {
  local host="${1:-}"

  if [[ -z "$host" ]]; then
    echo "Error: network command requires a host." >&2
    echo "Usage: diagnostic network <host>" >&2
    return 2
  fi

  if [[ ! "$host" =~ ^[A-Za-z0-9._:-]+$ ]]; then
    echo "Error: invalid host: $host" >&2
    return 2
  fi

  local resolved=""

  if command -v getent >/dev/null 2>&1; then
    resolved=$(getent ahostsv4 "$host" 2>/dev/null | awk 'NR==1 {print $1}')
    [[ -n "$resolved" ]] || resolved=$(getent hosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')
  fi

  if [[ -z "$resolved" ]] && command -v nslookup >/dev/null 2>&1; then
    resolved=$(nslookup "$host" 2>/dev/null | awk '/^Address: / {print $2; exit}')
  fi

  if [[ -z "$resolved" ]]; then
    echo "Error: unable to resolve host: $host" >&2
    return 1
  fi

  echo "Host: $host"
  echo "Resolved address: $resolved"

  if command -v ping >/dev/null 2>&1; then
    if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
      echo "Connectivity: reachable"
      return 0
    fi

    echo "Connectivity: host resolved but ping did not reply." >&2
    return 1
  fi

  echo "Connectivity: host resolved (ping unavailable)"
  return 0
}

disk_info() {
  echo "========== Disk Information =========="

  if ! command -v df >/dev/null 2>&1; then
    echo "Error: df command is not available." >&2
    return 1
  fi

  if ! df -h; then
    echo "Error: unable to read disk information." >&2
    return 1
  fi

  echo "======================================"
}

if [[ $# -eq 0 ]]; then
  echo "Error: missing command." >&2
  show_help >&2
  exit 2
fi

COMMAND="$1"
shift

case "$COMMAND" in
  system)
    if [[ $# -ne 0 ]]; then
      echo "Error: system does not accept additional arguments." >&2
      exit 2
    fi
    system_info
    ;;
  network)
    if [[ $# -ne 1 ]]; then
      echo "Error: network requires exactly one host." >&2
      echo "Usage: diagnostic network <host>" >&2
      exit 2
    fi
    network_check "$1"
    ;;
  disk)
    if [[ $# -ne 0 ]]; then
      echo "Error: disk does not accept additional arguments." >&2
      exit 2
    fi
    disk_info
    ;;
  help|-h|--help)
    if [[ $# -ne 0 ]]; then
      echo "Error: help does not accept additional arguments." >&2
      exit 2
    fi
    show_help
    ;;
  *)
    echo "Error: invalid command: $COMMAND" >&2
    show_help >&2
    exit 2
    ;;
esac
