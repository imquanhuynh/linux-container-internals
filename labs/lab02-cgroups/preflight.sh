#!/usr/bin/env bash
# Read-only cgroups v2 preflight. This script does not modify the host.
set -u

section() {
  printf '\n=== %s ===\n' "$1"
}

section "Timestamp and identity"
date -Is 2>/dev/null || date
id

section "Operating system and kernel"
PRETTY_NAME="unknown"
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
fi
printf 'OS: %s\n' "$PRETTY_NAME"
uname -a
printf 'Bash: %s\n' "$BASH_VERSION"

section "cgroup filesystem"
fs_type="$(stat -fc %T /sys/fs/cgroup 2>/dev/null || printf unknown)"
mount_options="$(findmnt -no OPTIONS /sys/fs/cgroup 2>/dev/null || true)"
printf 'Filesystem type: %s\n' "$fs_type"
if [[ -n "$mount_options" ]]; then
  printf 'Mount options: %s\n' "$mount_options"
else
  echo "Mount options: unavailable"
fi
printf 'Available controllers: '
if [[ -r /sys/fs/cgroup/cgroup.controllers ]]; then
  cat /sys/fs/cgroup/cgroup.controllers
else
  echo "unavailable"
fi
printf 'Enabled child controllers: '
if [[ -r /sys/fs/cgroup/cgroup.subtree_control ]]; then
  cat /sys/fs/cgroup/cgroup.subtree_control
else
  echo "unavailable"
fi
printf 'Root cgroup type: '
if [[ -r /sys/fs/cgroup/cgroup.type ]]; then
  cat /sys/fs/cgroup/cgroup.type
else
  echo "unavailable"
fi
if [[ -w /sys/fs/cgroup ]]; then
  echo "Root cgroup writable by current identity: yes"
else
  echo "Root cgroup writable by current identity: no"
fi

controllers="$(cat /sys/fs/cgroup/cgroup.controllers 2>/dev/null || true)"
for controller in cpu memory; do
  if [[ " $controllers " == *" $controller "* ]]; then
    printf 'Controller %s available: yes\n' "$controller"
  else
    printf 'Controller %s available: no\n' "$controller"
  fi
done

section "Tool versions"
if command -v docker >/dev/null 2>&1; then
  docker --version
else
  echo "Docker CLI: not installed or not in PATH"
fi
if command -v stress-ng >/dev/null 2>&1; then
  stress-ng --version 2>&1 | head -n 1
else
  echo "stress-ng: not installed or not in PATH"
fi
if command -v python3 >/dev/null 2>&1; then
  python3 --version
else
  echo "Python 3: not installed or not in PATH"
fi

section "Preflight decision"
if [[ "$fs_type" != "cgroup2fs" ]]; then
  echo "STOP: cgroups v2 is not confirmed."
elif [[ " $controllers " != *" cpu "* || " $controllers " != *" memory "* ]]; then
  echo "STOP: cpu and/or memory controller is unavailable."
elif [[ ",$mount_options," == *,ro,* ]]; then
  echo "STOP: cgroup filesystem is mounted read-only."
elif [[ ! -w /sys/fs/cgroup ]]; then
  echo "STOP: current identity cannot write to the cgroup root."
else
  echo "BASIC CHECKS PASSED: inspect delegation and hierarchy before making changes."
fi
