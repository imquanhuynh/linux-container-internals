# Lab 02 — Acceptance Criteria

A phase is complete only when its explanation, execution, troubleshooting, and documentation are supported by evidence.

## Required acceptance

- [ ] **Explain:** Explain cgroups v2 hierarchy, controller availability vs child-controller enablement, delegation, CPU quota/period, and memory accounting.
- [ ] **Preflight:** Capture OS, kernel, identity, cgroup filesystem/mount, controllers, current cgroup path, Docker version, and daemon cgroup configuration where available.
- [ ] **Execute — CPU:** Capture actual `cpu.max`, two `cpu.stat` samples, Docker configuration (if Docker experiment is run), and compare counter deltas.
- [ ] **Execute — Memory:** Capture actual `memory.max`, `memory.current`, and `memory.events`; record before/after samples where meaningful.
- [ ] **Execute — hierarchy:** Create a child cgroup only in an explicitly delegated writable subtree, and prove process placement with PID plus `cgroup.procs`. If no safe delegated subtree exists, record the exact observed blocker; do not alter host hierarchy to force completion.
- [ ] **Troubleshoot:** Record an actual failure or controlled diagnostic exercise, hypothesis, checks, root cause if established, and resolution/workaround. Do not invent an error.
- [ ] **Cleanup:** Verify lab containers/processes/child cgroups are removed and no unrelated process was moved.
- [ ] **Document:** Include reproducible commands, actual output, environment/version, interpretation, limitations, security implications, and screenshots.
- [ ] **Review:** Inspect the final diff and ensure no secrets or unsupported claims are committed.

## Evidence provenance

- Raw terminal output belongs in `evidence/raw/`.
- Screenshots belong in `evidence/screenshots/`.
- Analysis belongs in `results/`.
- Transcriptions from screenshots must be explicitly labelled as transcriptions, not raw output.
- Missing evidence must remain marked missing.

## Status rules

- **Done:** all required acceptance items are met with reviewed evidence.
- **Blocked:** a verified environment/tool/permission constraint prevents a required experiment and no safe alternative exists.
- **Continue:** work remains and no hard blocker has been demonstrated.
