# Lab 02 — Linux cgroups v2: CPU & Memory Control

> Status: In Progress
> Category: Linux Kernel Internals / Resource Management
> Difficulty: Beginner → Intermediate
> Estimated Time: 45–60 minutes
> Environment: Ubuntu 24.04 LTS, Linux kernel 6.x

## Objective

Understand how Linux cgroups v2 control process resources and how container runtimes expose the same primitives through Docker resource limits.

## Learning Goals

- Identify whether the host uses cgroups v2.
- Understand cgroup.controllers, cgroup.subtree_control, cgroup.procs, cpu.max, and memory.max.
- Create a dedicated cgroup for an experiment.
- Move a process into the cgroup.
- Observe CPU throttling.
- Observe a memory limit and OOM behavior.
- Connect Linux cgroups to Docker resource flags.
- Document troubleshooting and security implications.

## Architecture

    Linux Kernel
         |
      cgroups v2
         |
    +----+----+
    |         |
  cpu.max  memory.max
    |         |
CPU control  Memory control
    |         |
    +----+----+
         |
    application process
         |
      container
         |
       Docker

## Prerequisites

    uname -a
    mount | grep cgroup
    stat -fc %T /sys/fs/cgroup
    cat /sys/fs/cgroup/cgroup.controllers

Expected on a normal cgroups v2 host:

    cgroup2fs

Do not continue until you understand whether the host uses cgroups v1 or v2.

## Lab Workflow

1. Inspect the cgroup hierarchy.
2. Create a dedicated child cgroup.
3. Enable CPU and memory controllers in the parent.
4. Apply CPU and memory limits.
5. Run a controlled workload.
6. Move the workload into the cgroup.
7. Observe cpu.stat and memory.events.
8. Compare the Linux experiment with Docker resource limits.
9. Record actual evidence and troubleshooting.

## Step 1 — Inspect cgroups v2

    mount | grep cgroup
    cat /sys/fs/cgroup/cgroup.controllers
    cat /sys/fs/cgroup/cgroup.subtree_control

Record filesystem type, available controllers, and controllers currently enabled for child cgroups.

## Step 2 — Create the Lab cgroup

    sudo mkdir /sys/fs/cgroup/devops-cgroups-lab
    echo "+cpu +memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control

Verify:

    cat /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/devops-cgroups-lab/cgroup.controllers

If the command fails, stop and document the exact error before changing system configuration.

## Step 3 — Apply CPU Limit

Example target: 20% of one CPU.

    echo "20000 100000" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/cpu.max
    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.max

## Step 4 — Run CPU Workload

Check for stress-ng:

    stress-ng --version

If needed:

    sudo apt update
    sudo apt install -y stress-ng

Start a short workload:

    stress-ng --cpu 1 --timeout 30s &
    PID=$!
    echo "PID=$PID"

Move it into the cgroup:

    echo "$PID" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs

Observe:

    cat /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs
    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.stat

Questions:
- Does nr_throttled change?
- What happens when the workload is limited to 20%?
- What is the difference between CPU usage and CPU throttling?

## Step 5 — Apply Memory Limit

Use a conservative VM-safe limit:

    echo "128M" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/memory.max
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.max

Run a controlled allocation:

    python3 -c 'a=bytearray(256*1024*1024); import time; time.sleep(30)' &
    PID=$!
    echo "PID=$PID"
    echo "$PID" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs

Observe:

    cat /sys/fs/cgroup/devops-cgroups-lab/memory.current
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.events

Questions:
- Did the process survive?
- Did oom or oom_kill increment?
- What does memory.max actually enforce?

## Step 6 — Docker Connection

Run a container with explicit resource constraints:

    docker run --rm --memory=128m --cpus=0.5 busybox sh -c 'echo container-started; sleep 20'
    docker stats --no-stream

Explain which Linux kernel mechanism ultimately enforces Docker memory and CPU settings.

## Expected Evidence

- cgroups v2 detection;
- available controllers;
- created cgroup;
- CPU limit;
- cpu.stat before/after workload;
- memory limit;
- memory.events;
- Docker resource limits;
- any errors encountered.

Do not invent output. Paste the actual output into the lab notes.

## Troubleshooting Challenge

If enabling controllers returns an error such as Device or resource busy, diagnose before changing system configuration.

Investigate:

    cat /sys/fs/cgroup/cgroup.type
    cat /sys/fs/cgroup/cgroup.procs | head
    cat /sys/fs/cgroup/cgroup.subtree_control

Explain the cgroups v2 rules around enabling controllers and moving processes between parent and child cgroups.

## Production Insight

cgroups are the resource-control primitive behind practical container limits. They matter for CPU fairness, Kubernetes requests/limits, OOM behavior, capacity planning, and noisy-neighbor control.

## Security Insight

Resource limits are also a security control. A workload that can consume unlimited CPU or memory can create a denial-of-service condition. cgroups reduce blast radius but do not replace namespaces, capabilities, seccomp, AppArmor/SELinux, or network controls.

## Lessons Learned

Fill this section only after completing the experiment:
- What problem do cgroups solve?
- What is a cgroup in v2?
- What does cpu.max mean?
- What does memory.max mean?
- What evidence proves throttling or OOM behavior?
- How does Docker map resource flags to Linux primitives?

## Definition of Done

- [ ] cgroups v2 identified.
- [ ] Dedicated cgroup created.
- [ ] CPU controller enabled and limit tested.
- [ ] Memory controller enabled and limit tested.
- [ ] Actual cpu.stat / memory.events evidence captured.
- [ ] Docker resource-limit connection explained.
- [ ] Troubleshooting challenge documented.
- [ ] Production and security insights written.
- [ ] README completed with actual observations.
- [ ] Evidence/screenshots/diagram added where useful.
- [ ] Commit created and pushed.

## Suggested Commit

    lab02: explore Linux cgroups v2 resource limits

## Next Lab

Only after this lab is genuinely Done: Lab 03 — OverlayFS / Copy-on-Write.

The existing OverlayFS README will then be converted from documentation-only to an evidence-backed completed lab.