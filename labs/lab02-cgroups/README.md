# Lab 02 — Linux cgroups v2: CPU & Memory Control

> Status: In Progress  
> Category: Linux Kernel Internals / Resource Management  
> Estimated time: 45–60 minutes  
> Target environment: disposable Ubuntu 24.04 LTS VM, Linux kernel 6.x

## Objective

Understand how cgroups v2 constrain process resources and how Docker exposes CPU and memory limits through Linux kernel resource-control mechanisms.

## Learning goals

- Identify cgroups v2 and available controllers.
- Understand cgroup.controllers, cgroup.subtree_control, cgroup.procs, cpu.max, cpu.stat, memory.max and memory.events.
- Create a dedicated cgroup and move a controlled workload into it.
- Observe CPU throttling and memory-limit/OOM counters.
- Compare direct cgroup controls with Docker resource flags.
- Record actual evidence, troubleshooting and security implications.

## Safety and prerequisites

Use a disposable lab VM, not a production host. Enabling controllers at the root hierarchy can affect host-wide cgroup delegation. Do not remount cgroupfs, force controller changes or alter systemd configuration to make the lab pass.

Run the read-only preflight first:

    sudo bash labs/lab02-cgroups/preflight.sh

Stop if the filesystem is not cgroup2fs, CPU or memory controllers are unavailable, the mount is read-only, or the hierarchy is not writable/delegated. A successful basic preflight is not proof that every later write will succeed.

## Architecture

    Docker flags (--cpus / --memory)
                 |
                 v
       Container runtime configures cgroups
                 |
                 v
       cgroups v2: cpu.max / memory.max
                 |
                 v
          Kernel enforces limits
                 |
                 v
             Workload

The direct Linux experiment writes the same cgroup control files without Docker.

## Lab workflow

1. Inspect OS, kernel, cgroup filesystem, mount options and controllers.
2. Create a dedicated child cgroup on the disposable VM.
3. Enable CPU and memory controllers only after the preflight and safety checks.
4. Apply a CPU quota and compare cpu.stat before/after a workload.
5. Apply a memory limit and compare memory.events before/after an allocation.
6. Run a short Docker container with CPU/memory limits and inspect its configuration and live stats.
7. Record actual output, errors, diagnosis and cleanup in evidence.md.

Follow the commands in commands.md. Do not copy expected output into the evidence record.

## Important interface details

- cpu.max uses quota and period in microseconds. For example, 20000 100000 is approximately 20% of one logical CPU.
- memory.max accepts a byte count or max; 134217728 bytes is 128 MiB. Do not write a human-readable value such as 128M to this kernel interface.
- cpu.stat counters such as nr_throttled and throttled_usec help establish CPU throttling.
- memory.events counters such as oom and oom_kill help investigate memory-limit events. Interpret before/after deltas alongside exit status and logs.
- Move the shell into the target cgroup before exec-ing a workload so child processes inherit the intended cgroup; launching workers first and moving only the parent can create a race.

## Troubleshooting

If enabling controllers or moving a process fails, capture the exact error first. Inspect:

    cat /sys/fs/cgroup/cgroup.type
    cat /sys/fs/cgroup/cgroup.procs | head
    cat /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/devops-cgroups-lab/cgroup.controllers

Possible causes include cgroup v1 rather than v2, unavailable controllers, a read-only mount, systemd delegation, or cgroups v2 hierarchy rules. Treat these as hypotheses until output verifies the cause.

## Production insight

cgroups support CPU fairness, memory containment, capacity planning and noisy-neighbor control. Configured limits are not the same as observed usage; counters and workload behavior provide the evidence needed for incident analysis.

## Security insight

Resource limits reduce the blast radius of CPU or memory exhaustion and can help mitigate denial-of-service conditions. They do not replace namespaces, Linux capabilities, seccomp, AppArmor/SELinux or network controls.

## Interview question

A container configured with a 128 MiB memory limit exits unexpectedly. How would you distinguish a cgroup OOM kill from an application crash?

A strong answer correlates the container exit status and logs with the configured memory limit and before/after cgroup memory.events counters. Do not infer OOM solely from the fact that the process exited.

## Lessons learned

Complete this section only after running the experiments:

- What problem do cgroups solve?
- What does cpu.max mean?
- What evidence demonstrates throttling?
- What does memory.max enforce, and how do oom/oom_kill counters help?
- How do Docker resource flags relate to kernel cgroups?
- What failed, what evidence supports the diagnosis, and what would you change in production?

## Definition of Done

- [ ] cgroups v2 and controllers verified on the target VM.
- [ ] Dedicated cgroup created and workload placement verified.
- [ ] CPU quota tested with actual cpu.stat before/after.
- [ ] Memory limit tested with actual memory.events before/after.
- [ ] Docker limits inspected and live stats captured, or exact blocker recorded.
- [ ] Troubleshooting and lessons learned documented.
- [ ] evidence.md completed using actual VM output.
- [ ] Screenshot/diagram added where useful.
- [ ] README/commands reviewed and commit pushed.

## Next lab

Only after Lab 02 has reproducible evidence: Lab 03 — OverlayFS / Copy-on-Write.
