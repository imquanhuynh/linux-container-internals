# Lab 02 — Evidence Record

> Status: In Progress. Fill this file with output from the target Ubuntu VM only. Do not paste simulated or assistant-generated output as actual evidence.

## Environment

- Date/time and timezone:
- OS and version:
- Kernel:
- Shell:
- Docker Engine / CLI:
- stress-ng:
- cgroup filesystem:
- cgroup mount options:
- Available controllers:
- Enabled child controllers:
- VM type / resource allocation (if known):

## Preflight

### Command

    sudo bash labs/lab02-cgroups/preflight.sh

### Actual output

    [Paste the complete actual output here.]

### Expected vs actual

- Expected:
- Actual:
- Result: Pass / Fail / Not run

## Cgroup setup

### Commands

    sudo mkdir /sys/fs/cgroup/devops-cgroups-lab
    echo "+cpu +memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/cgroup.subtree_control
    cat /sys/fs/cgroup/devops-cgroups-lab/cgroup.controllers

### Actual output

    [Paste actual output and any error.]

### Observation

- Was the hierarchy writable/delegated?
- Were both controllers available to the child cgroup?
- If setup failed, what evidence supports the diagnosis?

## CPU experiment

### Configuration and commands

    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.max
    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.stat
    sudo bash -c 'echo $$ > /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs; exec stress-ng --cpu 1 --timeout 30s'
    cat /sys/fs/cgroup/devops-cgroups-lab/cpu.stat

### Actual output

    [Paste cpu.max, cpu.stat before/after, workload exit status and errors.]

### Expected vs actual

- Expected:
- Actual:
- Did nr_throttled change?
- Did throttled_usec change?
- Result: Pass / Fail / Not run

## Memory experiment

### Configuration and commands

    echo "134217728" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/memory.max
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.events
    sudo bash -c 'echo $$ > /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs; exec python3 -c "a=bytearray(268435456); import time; time.sleep(5)"'
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.current
    cat /sys/fs/cgroup/devops-cgroups-lab/memory.events

### Actual output

    [Paste memory.max, memory.events before/after, exit status and errors.]

### Expected vs actual

- Expected:
- Actual:
- Did oom or oom_kill increment?
- Result: Pass / Fail / Not run

Do not claim OOM was the cause unless the counters, exit status and related logs support that conclusion.

## Docker resource limits

### Commands

    LAB_CONTAINER="cgroups-lab-$(date +%s)"
    docker run -d --name "$LAB_CONTAINER" --memory=128m --cpus=0.5 busybox sh -c 'sleep 60'
    docker inspect --format 'Memory={{.HostConfig.Memory}} NanoCpus={{.HostConfig.NanoCpus}}' "$LAB_CONTAINER"
    docker stats --no-stream "$LAB_CONTAINER"
    docker rm -f "$LAB_CONTAINER"

### Actual output

    [Paste docker run, inspect, stats and cleanup output.]

### Docker → cgroups analysis

- What values did docker inspect report?
- What did docker stats show while the container was running?
- If unavailable, what exact error was returned?

## Troubleshooting

- Problem:
- Exact error / evidence:
- Hypothesis:
- Verified root cause, or why it remains unverified:
- Fix or safe next step:
- Verification after fix:

## Production insight

[Explain what the observed counters mean for CPU fairness, memory containment, noisy neighbors or incident response.]

## Security insight

[Explain how resource limits reduce resource-exhaustion risk and what other isolation controls remain necessary.]

## Interview question

How would you distinguish a cgroup OOM kill from an application crash when a container exits under a memory limit?

[Write an evidence-based answer using exit status, logs, memory.events and the configured limit.]

## Lessons learned

- 
- 
- 

## Evidence attachments

- Screenshot path(s):
- Diagram path:
- Additional logs:

## Final checklist

- [ ] Environment and tool versions recorded
- [ ] Preflight output is actual and reproducible
- [ ] cgroups v2 and controller availability verified
- [ ] Cgroup setup output or exact blocker recorded
- [ ] cpu.max and cpu.stat before/after captured
- [ ] memory.max and memory.events before/after captured
- [ ] Docker configuration and live stats captured, or exact blocker recorded
- [ ] Expected vs actual results documented
- [ ] Troubleshooting distinguishes hypotheses from verified root cause
- [ ] Production/security insights and lessons learned completed
- [ ] Screenshot or diagram added where useful
- [ ] Cleanup completed or remaining processes explained
