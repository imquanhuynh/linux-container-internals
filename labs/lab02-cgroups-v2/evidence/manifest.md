# Lab 02 — Evidence Manifest

> **Collection status: PENDING.** This file is an index/template only. No fresh VM output has been supplied or verified yet.

## Raw terminal output

Save original output in this directory's `raw/` subdirectory.

| Evidence | Expected filename | What it must prove | Status |
|---|---|---|---|
| Preflight | `00-preflight-<timestamp>.txt` | Timestamp, identity, OS/kernel, CPU/RAM, cgroup v2 mount/controllers, Docker daemon info where available | Pending |
| Current cgroup | `01-current-cgroup-YYYY-MM-DD.txt` | Current PID, `/proc/<PID>/cgroup`, resolved path, permissions, controllers and subtree state | Pending |
| systemd unit | `02-systemd-delegation-YYYY-MM-DD.txt` | Actual owning unit, `ControlGroup`, `Delegate=`, user manager unit where available | Pending |
| Delegation marker | `03-delegation-marker-YYYY-MM-DD.txt` | Ancestor/candidate directory ownership, permissions, controllers, `user.delegate` result and errno | Pending |
| Child placement | `04-child-placement-YYYY-MM-DD.txt` | Only if the decision gate passes: child path, test PID, PID visible in child `cgroup.procs`, process and child cleanup | Not run |
| Blocker | `04-delegation-blocker-YYYY-MM-DD.txt` | Exact observed reason the safe delegation gate did not pass | Not run |
| Cleanup | `05-cleanup-YYYY-MM-DD.txt` | Only Lab02-owned containers/resources checked; final absence or remaining-resource explanation | Pending |

Use either the child-placement log or blocker log for this phase. Do not fabricate both.

## Screenshots

Screenshots are supplemental; raw logs are the primary evidence.

- `screenshots/01-systemd-delegation.png` — actual unit name and `Delegate=`/ControlGroup result, if readable.
- `screenshots/02-child-placement.png` — PID visible in child `cgroup.procs`, or a clearly labelled blocker screenshot if the test cannot safely run.

Do not include secrets, tokens, unrelated process data, or private information.

## Acceptance mapping

| Requirement | Evidence |
|---|---|
| Explain delegation boundary and single-writer rule | `docs/systemd-delegation.md` plus analysis in `results/` |
| Execute read-only inspection | Preflight, current-cgroup, systemd-delegation and marker logs |
| Execute process placement or verify blocker | Child-placement log **or** blocker log |
| Troubleshoot | Actual error, hypothesis, diagnostic command, observed result and conclusion in `results/` |
| Cleanup | Cleanup log and child-cgroup removal result |
| Document | Results analysis, this manifest, and relevant screenshots |

## Provenance rules

- Raw logs must be captured from commands actually run on the lab VM.
- Keep expected output in the procedure document, not in raw evidence.
- Label copied/transcribed values as transcriptions; never call them raw output.
- If a command fails, preserve the exact error and record what was checked.
- Do not mark this phase or Lab 02 Done until the evidence is reviewed.
