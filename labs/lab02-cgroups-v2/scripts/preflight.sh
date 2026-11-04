#!/usr/bin/env bash
# Lab 02 fresh rebuild: read-only environment preflight.
# Run as the normal lab user. This script does not modify cgroup settings.
set -u

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/evidence/raw"
mkdir -p "$OUT"
LOG="$OUT/00-preflight-$(date +%Y%m%d-%H%M%S).txt"

{
  echo "=== LAB 02 FRESH PREFLIGHT ==="
  date --iso-8601=seconds 2>/dev/null || date
  echo
  echo "=== IDENTITY ==="
  id
  echo
  echo "=== OS ==="
  cat /etc/os-release
  echo
  echo "=== KERNEL ==="
  uname -a
  echo
  echo "=== CPU AND MEMORY ==="
  nproc
  free -h
  echo
  echo "=== CGROUP FILESYSTEM ==="
  stat -fc %T /sys/fs/cgroup 2>&1
  findmnt -no TARGET,ROOT,FSTYPE,OPTIONS /sys/fs/cgroup 2>&1 || true
  echo
  echo "=== CGROUP V2 FILES ==="
  for f in cgroup.controllers cgroup.subtree_control cgroup.type cgroup.procs; do
    echo "--- $f ---"
    if [[ -r "/sys/fs/cgroup/$f" ]]; then
      if [[ "$f" == "cgroup.procs" ]]; then
        head -n 10 "/sys/fs/cgroup/$f"
      else
        cat "/sys/fs/cgroup/$f"
      fi
    else
      echo "unavailable or unreadable"
    fi
  done
  echo
  echo "=== CURRENT PROCESS CGROUP ==="
  cat /proc/self/cgroup
  echo
  echo "=== TOOL VERSIONS ==="
  bash --version | head -n 1
  if command -v docker >/dev/null 2>&1; then
    docker --version
    echo "--- Docker daemon info (may require permission) ---"
    docker info --format 'ServerVersion={{.ServerVersion}} CgroupVersion={{.CgroupVersion}} CgroupDriver={{.CgroupDriver}}' 2>&1 || true
  else
    echo "Docker CLI: not installed"
  fi
  if command -v python3 >/dev/null 2>&1; then python3 --version; fi
} 2>&1 | tee "$LOG"

printf '\nSaved preflight evidence: %s\n' "$LOG"
