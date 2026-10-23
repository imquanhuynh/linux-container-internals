# Lab 02 — Linux cgroups v2 CPU & Memory Control

Run on a disposable Ubuntu 24.04 VM with systemd and cgroups v2. Do not run the mutating steps on a production host. Capture actual output; do not paste expected output as evidence.

## 1. Quick review and read-only preflight

    sudo bash labs/lab02-cgroups/preflight.sh

The preflight reports OS/kernel/tool versions, filesystem type, mount options, controllers and writability. It does not change the host. Stop if cgroups v2, CPU/memory controllers, writable mount or delegated hierarchy are not available. Do not remount cgroupfs or force controller changes.

## 2. Inspect the hierarchy

    uname -a
    cat /etc/os-release
    findmnt /sys/fs/cgroup
    stat -fc %T /sys/fs/cgroup
    cat /sys/fs/cgroup/cgroup.controllers
    cat /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/cgroup.procs | head

Expected filesystem type is cgroup2fs. Record the actual values and errors.

## 3. Create a dedicated cgroup

Only continue on the disposable lab VM after checking the preflight result and understanding that enabling controllers on the root hierarchy changes host-wide cgroup delegation.

    sudo mkdir /sys/fs/cgroup/devops-cgroups-lab
    echo "+cpu +memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/devops-cgroups-lab/cgroup.controllers

If a command fails, stop and capture the exact error plus cgroup.type, cgroup.procs and cgroup.subtree_control. Do not repeatedly retry or change systemd configuration without evidence.

## 4. CPU quota and throttling

A value of 20000 100000 means a 20,000-microsecond quota per 100,000-microsecond period, approximately 20% of one logical CPU.

    echo "20000 100000" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/cpu.max
    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.max
    echo "CPU stats before:"
    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.stat
    sudo bash -c 'echo $$ > /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs; exec stress-ng --cpu 1 --timeout 30s'
    echo "CPU stats after:"
    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.stat

The shell is moved into the target cgroup before it execs stress-ng, so stress-ng workers inherit the cgroup. Compare nr_throttled and throttled_usec before and after; CPU usage alone does not prove throttling. If stress-ng is missing, install it on the lab VM with apt before running the experiment.

## 5. Memory limit and OOM observation

The cgroup memory.max interface expects bytes or the word max. 134217728 bytes equals 128 MiB.

    echo "134217728" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/memory.max
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.max
    echo "Memory events before:"
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.events
    sudo bash -c 'echo $$ > /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs; exec python3 -c "a=bytearray(268435456); import time; time.sleep(5)"'
    echo "Workload exit status: $?"
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.current
    echo "Memory events after:"
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.events

The workload attempts a 256 MiB allocation under a 128 MiB limit. Depending on memory accounting and available memory, it may be OOM-killed. Compare the actual before/after oom and oom_kill counters and record the actual exit status. Do not claim an OOM kill unless the evidence supports it.

## 6. Docker resource limits

This uses a uniquely named, short-lived container so docker stats can inspect it while it is running.

    LAB_CONTAINER="cgroups-lab-$(date +%s)"
    docker run -d --name "$LAB_CONTAINER" --memory=128m --cpus=0.5 busybox sh -c 'sleep 60'
    docker inspect --format 'Memory={{.HostConfig.Memory}} NanoCpus={{.HostConfig.NanoCpus}}' "$LAB_CONTAINER"
    docker stats --no-stream "$LAB_CONTAINER"
    docker rm -f "$LAB_CONTAINER"

If Docker is unavailable, record the exact error and mark only the Docker sub-step as unavailable; do not fabricate output. Explain that Docker resource flags are enforced using kernel resource-control mechanisms, including cgroups.

## 7. Troubleshooting and cleanup

If a write fails, capture the exact error before diagnosing. Inspect:

    cat /sys/fs/cgroup/cgroup.type
    cat /sys/fs/cgroup/cgroup.procs | head
    cat /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/devops-cgroups-lab/cgroup.controllers

Distinguish cgroup v1/v2, missing controllers, a read-only mount, systemd delegation and the cgroups v2 no-internal-process rule. Call a cause "verified root cause" only when output supports it.

Before cleanup, confirm the lab workload has exited and the lab cgroup has no processes:

    cat /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs
    sudo rmdir /sys/fs/cgroup/devops-cgroups-lab

Do not blindly disable controllers on the root cgroup; other services may depend on the hierarchy. If processes remain, identify and stop only the lab workload.

## Evidence checklist

- [ ] OS, kernel, Bash, Docker and stress-ng versions recorded
- [ ] cgroups v2, mount options and controller availability verified
- [ ] Exact cgroup creation/controller-enable output recorded
- [ ] cpu.max and cpu.stat before/after captured
- [ ] memory.max and memory.events before/after captured
- [ ] Docker inspect configuration and live stats captured, or exact blocker recorded
- [ ] Expected vs actual, troubleshooting and verified root cause documented
- [ ] Production/security insights and lessons learned written
- [ ] Screenshot or diagram added where useful
- [ ] Evidence file contains only actual observations from the lab VM
