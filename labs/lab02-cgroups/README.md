# Lab 02 — Linux cgroups v2: CPU & Memory Control

> **Overall status: IN PROGRESS.** Docker CPU/memory observations are documented from six user-provided screenshots. Direct child-cgroup/process-placement evidence, the actual `cpu.max` output, and cleanup verification are still missing.

## Objective

Understand how Linux cgroups v2 organize processes and enforce resource limits, and compare Docker resource flags with kernel cgroup controls.

## Learning goals

- Verify cgroups v2 and CPU/memory controller availability.
- Explain `cgroup.controllers`, `cgroup.subtree_control`, `cgroup.procs`, `cpu.max`, `cpu.stat`, `memory.max`, `memory.current`, and `memory.events`.
- Apply and observe CPU and memory limits in Docker.
- Compare counters before and after a workload.
- Record real output, errors, cleanup, and security implications.

## Mental model

```text
Docker flags (--cpus / --memory)
              |
              v
       Docker configures cgroups
              |
              v
   cgroups v2 control files and counters
              |
              v
      Linux kernel enforces limits
              |
              v
            Process
```

Cgroups do not create a separate CPU or RAM pool. They group processes and let the kernel account for and constrain resource use.

## Files

- `commands.md` — guided experiments, safety checks, and commands.
- `preflight.sh` — read-only environment/cgroups preflight.
- `evidence.md` — lab record and acceptance checklist.
- `results/2026-10-30-docker-experiment.md` — analysis of the supplied screenshots.
- `evidence-logs/` — evidence transcribed from screenshots, plus explicit notes for evidence not yet captured. These are **not raw terminal captures**.
- `screenshots/` — six original terminal screenshots supplied for this lab.
- `APPLY-TO-REPO-WINDOWS.md` — safe instructions for merging this package into the existing Windows Git working tree.

## What the current evidence supports

- Ubuntu 26.04.1 LTS, kernel `7.0.0-42-generic`, 2 visible CPUs, approximately 3.3 GiB RAM, no swap.
- Unified cgroups v2 filesystem (`cgroup2fs`) and CPU/memory controllers listed as available.
- Docker CPU configuration equivalent to 0.5 CPU; `nr_throttled` and `throttled_usec` increased between captured samples.
- Docker memory limit of 128 MiB; observed current usage was below that limit.
- No OOM event was observed in the captured memory sample.

## Remaining work

1. Capture actual `cpu.max` output from the running CPU container, if it still exists.
2. Complete a direct child-cgroup/process-placement experiment only in an explicitly delegated, writable subtree; otherwise record the exact verified blocker.
3. Capture actual preflight and cleanup command output.
4. Update the repository's curriculum state only after its acceptance criteria are satisfied.
5. Review changes, commit, and push only after checking the final diff.

## Safety

Use a disposable VM. Do not force-enable controllers at the root hierarchy, remount cgroupfs, change systemd delegation on a production host, or move your shell/unrelated processes into a test cgroup. OOM experiments are optional and only for a disposable VM.

## Definition of Done

- [ ] cgroups v2 and CPU/memory controller availability verified.
- [ ] Direct child cgroup created safely, or a specific blocker captured.
- [ ] Workload placement verified using `cgroup.procs`.
- [ ] Actual `cpu.max` and `cpu.stat` before/after captured.
- [ ] `memory.max` and `memory.events` before/after captured.
- [x] Docker CPU/memory configuration and screenshot-based observations documented.
- [ ] Raw command output and cleanup verification saved.
- [ ] Screenshots/logs accurately labelled and reviewed.
- [ ] Changes reviewed and committed to GitHub.

**Do not mark the overall lab complete based only on Docker screenshots.**
