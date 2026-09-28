# DevOps/System Curriculum State

> Source of truth for the learning automation. Status is based on verified GitHub repository state and should be updated only when a lab has reproducible evidence.

## Career Track

System / Infrastructure → DevOps → DevSecOps

## Portfolio Repository

https://github.com/imquanhuynh/linux-container-internals

## Current Milestone

**System/Linux → Container Internals**

## Canonical Container-Internals Sequence

| # | Topic | Status | Evidence / Notes |
|---|---|---|---|
| 01 | Linux PID Namespace | ✅ Done | Root README marks the lab completed; historical lab documentation exists in commit history. Do not reteach the core concept. |
| 02 | Linux cgroups | ⏭️ Next | No current lab02-cgroups README found. This is the next allowed topic. |
| 03 | OverlayFS / Copy-on-Write | 🟡 In Progress | labs/lab02-overlayfs/README.md exists, but the screenshots directory is empty. Treat as incomplete until the experiment is reproduced and documented. |
| 04 | Network Namespace | ⏳ Planned | Blocked by previous prerequisites. |
| 05 | veth Pair + Linux Bridge | ⏳ Planned | Blocked by previous prerequisites. |
| 06 | iptables + NAT | ⏳ Planned | Blocked by previous prerequisites. |
| 07 | Rootless Containers | ⏳ Planned | Blocked by previous prerequisites. |
| 08 | Linux Capabilities | ⏳ Planned | Blocked by previous prerequisites. |
| 09 | Seccomp + AppArmor | ⏳ Planned | Blocked by previous prerequisites. |
| 10 | Mini Container Runtime | ⏳ Planned | Blocked by previous prerequisites. |

## Decision Rules

1. Never infer completion from a README existing alone.
2. A lab is **Done** only when there is reproducible evidence: commands/output plus relevant screenshots/diagram and lessons learned.
3. If a topic has a partially written README but lacks evidence, status is **In Progress**.
4. Do not skip cgroups to work on OverlayFS merely because OverlayFS documentation already exists.
5. Do not advance beyond a prerequisite because of the calendar.
6. If the user reports a lab was completed locally but GitHub evidence is missing, treat it as **Continue** and make evidence/documentation the next task.
7. Every completed milestone should leave a portfolio-grade GitHub artifact.

## Daily State Format

At the end of each lesson/lab, report exactly one:

- **Done** — acceptance criteria and GitHub evidence are complete.
- **Blocked** — a real environment/knowledge/tool blocker prevents completion.
- **Continue Tomorrow** — work remains, but there is no hard blocker.

Then provide:

- Current Milestone
- Completed
- In Progress
- Blocked
- Next Allowed Topic
- Next-Day Handoff
