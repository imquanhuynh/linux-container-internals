# Lab 02 — Commands and Guided Experiments

Use a disposable Ubuntu VM. Start with read-only checks. Stop if the cgroup mount/controllers are unavailable or the required hierarchy is not safely writable/delegated. Do not force controller changes on the root hierarchy.

## 1. Read-only environment checks

```bash
cat /etc/os-release
uname -r
nproc
free -h
bash --version | head -n 1
stat -fc %T /sys/fs/cgroup
findmnt /sys/fs/cgroup
cat /sys/fs/cgroup/cgroup.controllers
cat /sys/fs/cgroup/cgroup.subtree_control
cat /sys/fs/cgroup/cgroup.procs | head
```

- `stat -fc %T` should report `cgroup2fs` for a unified cgroups v2 mount.
- `cgroup.controllers` shows controllers available to child cgroups at that level.
- `cgroup.subtree_control` shows controllers enabled for child cgroups.
- These are not interchangeable: available does not necessarily mean enabled for children.

Run the repository's read-only preflight:

```bash
sudo bash labs/lab02-cgroups/preflight.sh
```

If `stress-ng` is not installed, install it only on the disposable lab VM:

```bash
sudo apt-get update
sudo apt-get install -y stress-ng
```

## 2. Docker CPU experiment (captured evidence)

Check for a name collision before creating the container:

```bash
sudo docker ps -a --filter name=lab02-cpu
```

If no pre-existing container with this name belongs to another task, create the workload:

```bash
sudo docker run -d \
  --name lab02-cpu \
  --cpus=0.5 \
  --memory=128m \
  python:3.12-slim \
  python -c 'import time; end=time.time()+120; x=0
while time.time()<end:
    x=(x+1)%1000003'
```

Inspect Docker's configured values:

```bash
sudo docker inspect lab02-cpu \
  --format 'NanoCPUs={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}}'
```

Inspect the cgroup controls and counters:

```bash
sudo docker exec lab02-cpu cat /sys/fs/cgroup/cpu.max
sudo docker exec lab02-cpu cat /sys/fs/cgroup/cpu.stat
sleep 5
sudo docker exec lab02-cpu cat /sys/fs/cgroup/cpu.stat
```

`--cpus=0.5` normally corresponds to 50,000 microseconds of quota per 100,000 microsecond period, but record the actual `cpu.max` output. Compare `nr_throttled` and `throttled_usec` before/after; do not infer throttling from the configured limit alone.

## 3. Docker memory experiment (captured evidence)

Check the name before creating the container:

```bash
sudo docker ps -a --filter name=lab02-memory
```

If the name is free for this lab:

```bash
sudo docker run -d \
  --name lab02-memory \
  --memory=128m \
  --memory-swap=128m \
  python:3.12-slim \
  python -c 'import time; x=bytearray(64*1024*1024); print("Allocated 64 MiB", flush=True); time.sleep(120)'
```

Inspect configuration and cgroup state:

```bash
sudo docker inspect lab02-memory \
  --format 'Memory={{.HostConfig.Memory}} MemorySwap={{.HostConfig.MemorySwap}}'
sudo docker exec lab02-memory cat /sys/fs/cgroup/memory.max
sudo docker exec lab02-memory cat /sys/fs/cgroup/memory.current
sudo docker exec lab02-memory cat /sys/fs/cgroup/memory.events
sudo docker inspect lab02-memory \
  --format 'Status={{.State.Status}} ExitCode={{.State.ExitCode}} OOMKilled={{.State.OOMKilled}}'
sudo docker logs lab02-memory
```

`memory.max` uses bytes or `max`, not a human-readable string. `memory.current` is the cgroup's currently accounted memory, not just the Python allocation. A zero `oom`/`oom_kill` counter means no such event was observed in that captured interval.

## 4. Direct child-cgroup experiment — do not bypass safety checks

The original lab requires a direct cgroup experiment. Before running any writes, review the preflight and root hierarchy state:

```bash
cat /sys/fs/cgroup/cgroup.type
cat /sys/fs/cgroup/cgroup.controllers
cat /sys/fs/cgroup/cgroup.subtree_control
cat /sys/fs/cgroup/cgroup.procs | head
findmnt -no OPTIONS /sys/fs/cgroup
```

**Important:** Writing `+cpu +memory` into `/sys/fs/cgroup/cgroup.subtree_control` changes root-level controller delegation and can fail because of systemd hierarchy rules or processes in the root cgroup. Do not run that write blindly, do not remount cgroupfs, and do not change systemd configuration to force the lab to pass. If the VM does not provide a delegated writable subtree, record the exact blocker and use an appropriately delegated disposable lab environment.

Only inside a cgroup subtree explicitly delegated for this lab, create a child cgroup and verify controllers are available before proceeding. Use the delegated path supplied by the environment rather than assuming `/sys/fs/cgroup` is writable. Record:
- exact delegated path and ownership/permissions;
- `cgroup.controllers` and `cgroup.subtree_control`;
- the child cgroup's `cpu.max` and `memory.max`;
- `cgroup.procs` before and after placing a controlled workload;
- `cpu.stat` and `memory.events` before/after;
- exact errors if any write is rejected.

Do not move your interactive shell or unrelated processes into a cgroup. A safe pattern is to start a dedicated short-lived child process directly in the target cgroup, and verify its PID in `cgroup.procs`.

## 5. Optional controlled OOM experiment

Optional only; use a disposable VM and do not run on production. A container may be OOM-killed.

```bash
sudo docker ps -a --filter name=lab02-memory-oom
```

If the name is unused by another task:

```bash
sudo docker run -d \
  --name lab02-memory-oom \
  --memory=64m \
  --memory-swap=64m \
  python:3.12-slim \
  python -c 'import time; x=bytearray(160*1024*1024); print("Allocated 160 MiB", flush=True); time.sleep(120)'
```

Check actual result:

```bash
sudo docker inspect lab02-memory-oom \
  --format 'Status={{.State.Status}} ExitCode={{.State.ExitCode}} OOMKilled={{.State.OOMKilled}}'
sudo docker logs lab02-memory-oom
```

Do not claim an OOM kill unless Docker state, exit status, logs, and/or before/after memory event counters support the conclusion.

## 6. Cleanup

Inspect only the lab containers first:

```bash
sudo docker ps -a \
  --filter name=lab02-cpu \
  --filter name=lab02-memory \
  --filter name=lab02-memory-oom
```

Remove only containers that you personally created for this lab:

```bash
sudo docker rm -f lab02-cpu lab02-memory lab02-memory-oom
```

Omit names for experiments you did not run. This removes containers, not images. For direct cgroups, verify the child cgroup has no processes before removing it; do not disable root controllers blindly.

## 7. Save actual command output

Capture actual output on the lab VM, for example:

```bash
mkdir -p labs/lab02-cgroups/evidence-logs
{
  date --iso-8601=seconds
  cat /etc/os-release
  uname -r
  nproc
  free -h
  stat -fc %T /sys/fs/cgroup
  findmnt /sys/fs/cgroup
  cat /sys/fs/cgroup/cgroup.controllers
  cat /sys/fs/cgroup/cgroup.subtree_control
} 2>&1 | tee labs/lab02-cgroups/evidence-logs/environment-and-cgroups.txt
```

Only save logs from commands actually run. Do not copy example numbers into evidence logs.
