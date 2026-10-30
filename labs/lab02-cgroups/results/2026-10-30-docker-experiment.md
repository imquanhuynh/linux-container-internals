# Lab 02 Results — Docker CPU & Memory Experiments

- **Capture date:** 2026-10-30
- **Evidence source:** six user-provided terminal screenshots
- **Scope:** Docker-based CPU and memory experiments only. Direct child-cgroup/process-placement objectives remain outstanding.

## Environment

| Item | Observed |
|---|---|
| OS | Ubuntu 26.04.1 LTS (`resolute`) |
| Kernel | `7.0.0-42-generic` |
| CPU visible to VM | 2 (`nproc`) |
| RAM | `free -h` reported 3.3 GiB total and 2.6 GiB available at capture time |
| Swap | 0 B |
| cgroup filesystem | `cgroup2fs` |
| Controllers shown | `cpuset cpu io memory hugetlb pids rdma misc dmem` |

The screenshots show a unified cgroups v2 filesystem. `cgroup.controllers` lists controllers available for child cgroups at that level; `cgroup.subtree_control` lists controllers enabled for child cgroups. These interfaces are related but not interchangeable.

## CPU limit and throttling

Docker configuration observed:
- `NanoCPUs=500000000`, equivalent to 0.5 CPU.
- `Memory=134217728` bytes, equivalent to 128 MiB.

Captured `cpu.stat` samples:

| Counter | Sample 1 | Sample 2 | Delta |
|---|---:|---:|---:|
| `usage_usec` | 3,769,372 | 7,779,081 | +4,009,709 |
| `user_usec` | 3,719,526 | 7,720,329 | +4,000,803 |
| `system_usec` | 49,846 | 58,751 | +8,905 |
| `nr_periods` | 75 | 155 | +80 |
| `nr_throttled` | 74 | 154 | +80 |
| `throttled_usec` | 3,628,205 | 7,696,468 | +4,068,263 |

**Interpretation:** CPU usage increased. `nr_throttled` increased by 80 and `throttled_usec` increased by 4,068,263, supporting that throttling occurred during the observation interval. `throttled_usec` is a kernel accounting counter, not a direct wall-clock measurement of user-perceived delay.

**Remaining evidence gap:** the supplied screenshots do not show the actual `cpu.max` output. Capture it from the running container if it still exists:

```bash
sudo docker exec lab02-cpu cat /sys/fs/cgroup/cpu.max
```

Record the actual value; do not assume the output.

## Memory limit and current usage

Observed Docker configuration:
- `Memory=134217728` bytes.
- `MemorySwap=134217728` bytes.
- `memory.max=134217728` bytes (128 MiB).
- `memory.current=71589888` bytes (approximately 68.25 MiB).

**Interpretation:** At the capture time, memory accounted to the cgroup was below the configured 128 MiB limit. `memory.current` is cgroup-accounted memory, not only the Python bytearray. With standard Linux Docker semantics, setting `--memory-swap` equal to `--memory` permits no additional swap beyond the memory limit.

## Memory events and state

Observed `memory.events` values:
- `low=0`
- `high=0`
- `max=0`
- `oom=0`
- `oom_kill=0`
- `oom_group_kill=0`
- `sock_throttled=0`

Observed Docker state:
- `Status=running`
- `ExitCode=0`
- `OOMKilled=false`

Application output showed `Allocated 64 MiB` twice. The screenshots do not establish why the line appeared twice. Do not infer a restart without checking `RestartCount` and timestamps.

**Interpretation:** No memory-limit/OOM event was observed in this sample, and Docker did not report the container as OOM-killed at capture time. This is a normal below-limit observation, not a reproduced OOM condition.

If the container still exists, investigate the duplicate output with:

```bash
sudo docker inspect lab02-memory   --format 'RestartCount={{.RestartCount}} StartedAt={{.State.StartedAt}}'
```

## Lessons learned

1. Docker resource flags configure resource controls; kernel cgroup files and counters help verify behavior.
2. `cpu.max` describes CPU quota and period. `cpu.stat` records usage and throttling counters.
3. `memory.max` is a byte-based memory limit. `memory.current` is the cgroup's live accounted memory.
4. Zero memory event counters are a valid result when the workload stays below the relevant thresholds.
5. Do not infer OOM solely from a container exit; correlate `OOMKilled`, exit code, logs and memory-event deltas.
6. This report proves the Docker CPU/memory sub-experiments only. Direct child-cgroup creation and process placement are separate acceptance criteria in the main lab.

## Status

- [x] Environment and cgroups v2 captured.
- [x] Docker CPU/memory limits inspected.
- [x] CPU throttling counters compared before/after.
- [x] Memory limit/current usage and events captured.
- [ ] Actual `cpu.max` output recorded.
- [ ] Direct child-cgroup and process-placement experiment completed or blocker documented.
- [ ] Cleanup and complete evidence record verified.

**Overall Lab 02 remains In Progress.**
