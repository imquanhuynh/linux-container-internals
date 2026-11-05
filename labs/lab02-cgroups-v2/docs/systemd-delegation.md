# Lab 02 — systemd cgroup delegation and process placement

> Procedure only. Do not mark this phase complete until the VM output has been captured and reviewed.

## Objective

Identify which systemd unit owns the current shell, determine whether a service/scope subtree is explicitly delegated, inspect the `user.delegate` marker, and prove process placement in a child cgroup only when the subtree is safely delegated and writable.

This phase does **not** change systemd configuration or enable controllers. It is a read-first exercise.

## Safety rules

- Run as the normal lab user; do not add `sudo` to bypass permission checks.
- Never write to `/sys/fs/cgroup` or to a systemd-managed unit that has not been explicitly delegated.
- Delegation is for service/scope units, not slice units.
- Do not create a child cgroup until the decision gate in Step 5 passes.
- Do not write to `cgroup.subtree_control` in this phase.
- If there is no clearly delegated, writable subtree, stop and save the exact blocker. That is a valid observation.
- Never move the interactive shell or an unrelated process.

## Evidence files

Save actual terminal output under `evidence/raw/`:

- `00-preflight-<timestamp>.txt` — created by `scripts/preflight.sh`.
- `01-current-cgroup-YYYY-MM-DD.txt` — current process cgroup and permissions.
- `02-systemd-delegation-YYYY-MM-DD.txt` — owning unit and `Delegate=` properties.
- `03-delegation-marker-YYYY-MM-DD.txt` — ancestor and user-manager cgroup inspection.
- `04-child-placement-YYYY-MM-DD.txt` — only if the safe child-cgroup test runs.
- `04-delegation-blocker-YYYY-MM-DD.txt` — if no safe delegated subtree is available.
- `05-cleanup-YYYY-MM-DD.txt` — cleanup verification.

Raw logs are primary evidence. A screenshot is optional; capture one only for the key unit/delegation result or the successful PID placement/blocker. Do not present expected values as actual output.

## Step 1 — preflight

From the repository root, switch to the rebuild branch and run the read-only preflight:

```bash
cd ~/linux-container-internals
git fetch origin
git switch lab02-rebuild-2026-11
git status --short --branch
bash labs/lab02-cgroups-v2/scripts/preflight.sh
```

The script creates a timestamped file in `labs/lab02-cgroups-v2/evidence/raw/`. It records identity, OS, kernel, CPU/RAM, cgroup mount/controllers, current process cgroup, and Docker daemon information where available.

**Check:** `stat -fc %T /sys/fs/cgroup` should report `cgroup2fs` for a unified cgroups v2 mount. If Docker access is denied, keep the exact error; do not switch to root just to hide it.

## Step 2 — locate the current process cgroup

```bash
STAMP="$(date +%F)"
OUT="labs/lab02-cgroups-v2/evidence/raw"
mkdir -p "$OUT"
set -o pipefail

{
  echo "=== TIMESTAMP ==="
  date -Is
  echo "=== IDENTITY / PID ==="
  id
  echo "PID=$$"
  echo "=== /proc/$$/cgroup ==="
  cat "/proc/$$/cgroup"

  CGROUP_REL="$(awk -F: '$1=="0" {print $3}' "/proc/$$/cgroup")"
  if [[ -z "$CGROUP_REL" ]]; then
    echo "ERROR: no unified cgroup path found"
    exit 1
  fi

  CGROUP_DIR="/sys/fs/cgroup${CGROUP_REL}"
  echo "CGROUP_REL=$CGROUP_REL"
  echo "CGROUP_DIR=$CGROUP_DIR"
  echo "=== DIRECTORY ==="
  stat -c '%A %U:%G %n' "$CGROUP_DIR" 2>&1
  echo "directory_writable=$([[ -w "$CGROUP_DIR" ]] && echo yes || echo no)"
  echo "directory_searchable=$([[ -x "$CGROUP_DIR" ]] && echo yes || echo no)"

  for f in cgroup.type cgroup.controllers cgroup.subtree_control cgroup.procs; do
    echo "--- $f ---"
    if [[ -r "$CGROUP_DIR/$f" ]]; then
      if [[ "$f" == "cgroup.procs" ]]; then
        head -n 15 "$CGROUP_DIR/$f"
      else
        cat "$CGROUP_DIR/$f"
      fi
    else
      echo "unavailable or unreadable"
    fi
  done
} 2>&1 | tee "$OUT/01-current-cgroup-$STAMP.txt"
```

**Check:** the path must correspond to the unified `0::...` entry. Record the actual directory owner, permissions, controllers, and subtree-control state. A readable cgroup directory is not automatically delegated.

## Step 3 — identify the owning systemd unit

```bash
STAMP="$(date +%F)"
OUT="labs/lab02-cgroups-v2/evidence/raw"

{
  echo "=== SYSTEMD VERSION ==="
  systemctl --version | head -n 1
  echo "=== UNIT OWNING THIS PID ==="
  systemctl status "$$" --no-pager --full
  echo "=== USER MANAGER UNIT ==="
  UID_NUM="$(id -u)"
  systemctl show "user@${UID_NUM}.service" \
    -p Id -p ActiveState -p ControlGroup -p Delegate -p Slice
} 2>&1 | tee "$OUT/02-systemd-delegation-$STAMP.txt"
```

Read the first line of `systemctl status "$$"` and copy its actual unit name (for example, a `session-*.scope`). Then inspect that exact unit:

```bash
UNIT="REPLACE_WITH_THE_ACTUAL_UNIT_NAME"
systemctl show "$UNIT" -p Id -p ActiveState -p ControlGroup -p Delegate -p Slice \
  2>&1 | tee -a "labs/lab02-cgroups-v2/evidence/raw/02-systemd-delegation-$(date +%F).txt"
```

Do not leave the placeholder unchanged. Do not assume the current shell's unit is delegated. `Delegate=yes` on a service/scope is the ownership boundary; a slice is not a valid delegation boundary.

## Step 4 — inspect the delegation marker and candidate subtree

The `user.delegate` extended attribute is a useful marker on sufficiently recent combinations (Linux 5.6+ and systemd 251+). Its absence alone does **not** prove that delegation is absent. Correlate it with the unit's `Delegate=` property, cgroup path, ownership, and permissions.

```bash
STAMP="$(date +%F)"
OUT="labs/lab02-cgroups-v2/evidence/raw"
CGROUP_REL="$(awk -F: '$1=="0" {print $3}' "/proc/$$/cgroup")"
CGROUP_DIR="/sys/fs/cgroup${CGROUP_REL}"
UID_NUM="$(id -u)"
USER_REL="$(systemctl show "user@${UID_NUM}.service" -p ControlGroup --value 2>/dev/null || true)"

inspect_cgroup_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  echo
  echo "=== $dir ==="
  stat -c '%A %U:%G %n' "$dir" 2>&1
  echo "directory_writable=$([[ -w "$dir" ]] && echo yes || echo no)"
  for f in cgroup.controllers cgroup.subtree_control cgroup.type; do
    echo "--- $f ---"
    if [[ -r "$dir/$f" ]]; then cat "$dir/$f"; else echo "unavailable or unreadable"; fi
  done

  python3 - "$dir" <<'PY'
import os, sys
path = sys.argv[1]
try:
    value = os.getxattr(path, "user.delegate")
    print(f"user.delegate={value.decode(errors='replace')!r}")
except OSError as exc:
    print(f"user.delegate unavailable: errno={exc.errno} ({exc.strerror})")
PY
}

{
  echo "=== TIMESTAMP ==="
  date -Is
  echo "=== CURRENT CGROUP AND ANCESTORS ==="
  p="$CGROUP_DIR"
  while [[ "$p" == /sys/fs/cgroup* ]]; do
    inspect_cgroup_dir "$p"
    [[ "$p" == /sys/fs/cgroup ]] && break
    p="$(dirname "$p")"
  done

  if [[ -n "$USER_REL" ]]; then
    echo
    echo "=== USER MANAGER CGROUP ==="
    echo "user@UID ControlGroup=$USER_REL"
    inspect_cgroup_dir "/sys/fs/cgroup${USER_REL}"
  else
    echo "user@UID ControlGroup: unavailable"
  fi
} 2>&1 | tee "$OUT/03-delegation-marker-$STAMP.txt"
```

**Check:** identify the exact service/scope path where `Delegate=` is enabled, if any. Confirm whether the current user can write/search that directory. Note whether `cpu` and `memory` appear in `cgroup.controllers` and `cgroup.subtree_control`; do not enable them in this phase.

## Step 5 — decision gate and child-process placement

Proceed only if **all** of the following are true:

1. You have identified an actual **service or scope** unit with `Delegate=yes` (or an explicit controller list).
2. You have resolved that unit's `ControlGroup` to a real directory below `/sys/fs/cgroup`.
3. The directory is clearly within that delegation boundary and is writable/searchable by the current user.
4. The candidate is not a slice and is not the cgroup root.
5. You can explain which manager owns the subtree below this boundary.

If any condition is false or uncertain, do not run the write test. Save the exact output and reason as `04-delegation-blocker-YYYY-MM-DD.txt`. Do not use `sudo`, edit systemd drop-ins, or change the root hierarchy to force success.

If all conditions pass, replace the path below with the verified delegated service/scope directory. This test creates one child cgroup, moves only a dedicated `sleep` process into it, verifies the PID, then removes the process and child. It does not enable CPU or memory controllers.

```bash
STAMP="$(date +%F)"
OUT="labs/lab02-cgroups-v2/evidence/raw"
DELEGATED_DIR="/sys/fs/cgroup/REPLACE_WITH_VERIFIED_CONTROL_GROUP_PATH"
CHILD=""
PID=""

cleanup_child() {
  if [[ -n "$PID" ]]; then
    kill "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
    PID=""
  fi
  if [[ -n "$CHILD" && -d "$CHILD" ]]; then
    rmdir "$CHILD" 2>/dev/null || echo "Cleanup note: child still exists: $CHILD"
  fi
}
trap cleanup_child EXIT
set -o pipefail

{
  echo "=== TIMESTAMP ==="
  date -Is
  echo "=== VERIFIED DELEGATED DIRECTORY ==="
  echo "$DELEGATED_DIR"

  case "$DELEGATED_DIR" in
    /sys/fs/cgroup/*) ;;
    *) echo "STOP: path must be below /sys/fs/cgroup"; exit 1 ;;
  esac

  if [[ ! -d "$DELEGATED_DIR" || ! -w "$DELEGATED_DIR" || ! -x "$DELEGATED_DIR" ]]; then
    echo "STOP: delegated directory is absent or not writable/searchable by this user"
    exit 1
  fi

  stat -c '%A %U:%G %n' "$DELEGATED_DIR"
  cat "$DELEGATED_DIR/cgroup.controllers"
  cat "$DELEGATED_DIR/cgroup.subtree_control"

  CHILD="$DELEGATED_DIR/lab02-process-test-$(date +%s)"
  mkdir "$CHILD" || exit 1
  echo "Created child: $CHILD"

  sleep 60 &
  PID=$!
  echo "Test PID=$PID"
  printf '%s\n' "$PID" > "$CHILD/cgroup.procs" || exit 1

  echo "=== CHILD cgroup.procs ==="
  cat "$CHILD/cgroup.procs"
  grep -Fx "$PID" "$CHILD/cgroup.procs" || exit 1
  ps -o pid,stat,comm -p "$PID"

  echo "=== STOP TEST PROCESS ==="
  kill "$PID"
  wait "$PID" 2>/dev/null || true
  PID=""

  echo "=== VERIFY EMPTY CHILD ==="
  cat "$CHILD/cgroup.procs"
  rmdir "$CHILD" || exit 1
  CHILD=""
  echo "Child cgroup removed successfully"
} 2>&1 | tee "$OUT/04-child-placement-$STAMP.txt"

trap - EXIT
```

If `mkdir` or the `cgroup.procs` write fails, preserve the exact error. The exit trap attempts to stop the test process and remove the child; verify cleanup in Step 6. Do not retry with elevated privileges.

## Step 6 — cleanup and final evidence check

First inspect only the known Lab02 containers:

```bash
for name in lab02-cpu lab02-memory; do
  if docker inspect "$name" >/dev/null 2>&1; then
    docker inspect "$name" --format '{{.Name}} status={{.State.Status}} pid={{.State.Pid}}'
  else
    echo "$name: not present"
  fi
done
```

Remove a container only if you confirm it was created for this Lab02 experiment and is no longer needed:

```bash
docker rm -f lab02-cpu lab02-memory
```

Then verify the known names are absent and record the result:

```bash
STAMP="$(date +%F)"
OUT="labs/lab02-cgroups-v2/evidence/raw"
{
  date -Is
  for name in lab02-cpu lab02-memory; do
    if docker inspect "$name" >/dev/null 2>&1; then
      echo "$name: STILL PRESENT"
    else
      echo "$name: absent"
    fi
  done
  echo "Review the child-placement log: the test child must have been removed."
} 2>&1 | tee "$OUT/05-cleanup-$STAMP.txt"
```

Do not remove unrelated containers or Docker images. Do not delete cgroup directories you did not create.

## What to write in the results report

Record only observed values:

- Current shell PID and `/proc/<PID>/cgroup` path.
- Owning unit name, `ControlGroup`, and actual `Delegate=` value.
- Kernel/systemd versions and `user.delegate` result (including errno if unavailable).
- Candidate delegated directory, owner/mode, controllers, and subtree-control state.
- Whether the decision gate passed.
- If the child test ran: child path, test PID, proof from `cgroup.procs`, and cleanup result.
- If blocked: exact command/error and which gate condition was not met.
- One troubleshooting hypothesis and the command/output that confirmed or rejected it.

## Completion rule

This phase is not Done merely because the commands ran. It is complete only when the delegation model is explained, the safe execute path or exact blocker is evidenced, the observed result is troubleshot, and logs/results are documented. Lab 02 as a whole remains In Progress until all acceptance criteria are met.
