# Lab 02 — Linux cgroups v2: CPU & Memory Control

> **Status: IN PROGRESS — fresh rebuild.** This directory is the clean replacement track. The original `labs/lab02-cgroups/` is preserved unchanged for rollback and historical reference.

## Objective

Demonstrate how Linux cgroups v2 accounts for processes and enforces CPU and memory resource limits, then compare direct kernel controls with Docker resource constraints.

## Learning outcomes

- [ ] Explain cgroups v2 hierarchy, controllers, and delegation.
- [ ] Verify the host environment and controller availability.
- [ ] Create and inspect a child cgroup only inside an explicitly delegated writable subtree.
- [ ] Verify process placement with `cgroup.procs`.
- [ ] Observe CPU quota through `cpu.max` and `cpu.stat`.
- [ ] Observe memory limits through `memory.max`, `memory.current`, and `memory.events`.
- [ ] Compare direct cgroup controls with Docker resource flags.
- [ ] Troubleshoot at least one observed issue or document a verified environment blocker.
- [ ] Clean up all lab-created resources and verify cleanup.
- [ ] Publish reproducible raw evidence and technical analysis.

## Lab phases

| Phase | Topic | Status |
|---|---|---|
| 00 | Environment preflight and repository setup | In Progress |
| 01 | cgroups v2 fundamentals and hierarchy | Not started |
| 02 | CPU controller | Not started |
| 03 | Memory controller | Not started |
| 04 | Delegated child cgroup and process placement | Not started |
| 05 | Docker integration | Not started |
| 06 | Troubleshooting and security analysis | Not started |
| 07 | Cleanup, evidence review, and acceptance | Not started |

## Directory map

- `docs/` — concepts, architecture, and phase notes.
- `scripts/` — read-only preflight and reproducible helper scripts.
- `experiments/` — command procedures and experiment definitions.
- `evidence/raw/` — captured terminal output from commands actually executed.
- `evidence/screenshots/` — contextual screenshots.
- `results/` — analysis based on verified evidence.

## Evidence rules

1. Record timestamp, OS, kernel, tool versions, exact command, and actual output.
2. Label expected output separately from actual output.
3. Never transcribe an expected value as an observation.
4. Keep secrets and personal data out of committed evidence.
5. Do not claim a controller event, OOM kill, or throttling without supporting counters/state.
6. Do not modify host-level cgroup controller settings merely to force an experiment to pass.

## Safety

Use a disposable Ubuntu VM. Start with read-only checks. Do not write to root-level `cgroup.subtree_control`, remount cgroupfs, change systemd delegation, or move unrelated processes. Direct cgroup experiments require an explicitly delegated writable subtree.

## Definition of Done

See [acceptance criteria](docs/acceptance-criteria.md). The lab remains In Progress until all required evidence is reviewed and cleanup is verified.
