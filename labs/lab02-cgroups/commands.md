# Lab 02 — Commands

## Inspect
uname -a
mount | grep cgroup
stat -fc %T /sys/fs/cgroup
cat /sys/fs/cgroup/cgroup.controllers
cat /sys/fs/cgroup/cgroup.subtree_control

## Create lab cgroup
sudo mkdir /sys/fs/cgroup/devops-cgroups-lab
echo "+cpu +memory" | sudo tee /sys/fs/cgroup/cgroup.subtree_control

## CPU
echo "20000 100000" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/cpu.max
stress-ng --cpu 1 --timeout 30s &
PID=$!
echo "$PID" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs
cat /sys/fs/cgroup/devops-cgroups-lab/cpu.stat

## Memory
echo "128M" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/memory.max
python3 -c 'a=bytearray(256*1024*1024); import time; time.sleep(30)' &
PID=$!
echo "$PID" | sudo tee /sys/fs/cgroup/devops-cgroups-lab/cgroup.procs
cat /sys/fs/cgroup/devops-cgroups-lab/memory.current
cat /sys/fs/cgroup/devops-cgroups-lab/memory.events

## Docker
docker run --rm --memory=128m --cpus=0.5 busybox sh -c 'echo container-started; sleep 20'
docker stats --no-stream

## Cleanup
sudo rmdir /sys/fs/cgroup/devops-cgroups-lab