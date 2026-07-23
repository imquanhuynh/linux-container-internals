# Lab 01 — Understanding Linux Namespaces Using `nsenter`

> **Category:** Linux Kernel Internals
> **Difficulty:** Beginner → Intermediate
> **Estimated Time:** 30–45 minutes
> **Prerequisites:** Basic Linux command line, Docker Engine

---

# Executive Summary

One of the biggest misconceptions among beginners is believing that a Docker container is a lightweight virtual machine.

In reality, Docker does **not** create a new operating system. Instead, Docker leverages existing Linux Kernel features—primarily **Namespaces** and **cgroups**—to isolate ordinary Linux processes.

The objective of this lab is to prove this statement experimentally.

Instead of relying on Docker commands, we will use the native Linux utility `nsenter` to enter a running container's namespaces and observe how process isolation is implemented by the Linux Kernel.

By the end of this lab, you will understand why a container is simply an isolated Linux process rather than a virtual machine.

---

# Learning Objectives

After completing this lab, you should be able to:

* Explain why Docker containers are Linux processes.
* Describe the purpose of Linux Namespaces.
* Identify the host PID of a running container.
* Enter an existing namespace using `nsenter`.
* Explain why the process list changes after entering the PID Namespace.
* Distinguish Docker containers from virtual machines.

---

# Background

Before Docker became popular, application deployment commonly relied on virtual machines.

Each virtual machine required its own guest operating system, consuming additional CPU, memory, and storage resources.

Linux Kernel introduced a more efficient approach by providing process isolation through **Namespaces**.

Instead of creating another operating system, Linux simply changes what a process is allowed to see.

Docker builds on top of these existing Kernel features.

When executing:

```bash
docker run nginx
```

Docker does not create a new kernel.

Instead, it:

* creates Linux Namespaces
* configures cgroups
* prepares the filesystem
* starts the container process

The container is still just another Linux process running on the host.

---

# Lab Scenario

This experiment consists of four stages.

```text
Host Linux

↓

Run Docker Container

↓

Locate Host PID

↓

Enter Container Namespace

↓

Compare Process Visibility
```

The goal is to compare what the host operating system sees versus what the container sees.

---

# Lab Environment

| Component        | Version              |
| ---------------- | -------------------- |
| Operating System | Ubuntu 24.04 LTS     |
| Linux Kernel     | 6.x                  |
| Docker Engine    | Latest Stable        |
| Container Image  | nginx:latest         |
| Utility          | nsenter (util-linux) |

---

# Namespace Overview

During this experiment we enter multiple namespaces.

| Namespace | Purpose                 |
| --------- | ----------------------- |
| PID       | Process isolation       |
| NET       | Network isolation       |
| IPC       | Shared memory isolation |
| UTS       | Hostname isolation      |
| MOUNT     | Filesystem isolation    |

Although this lab focuses primarily on PID Namespace, all of these namespaces are entered simultaneously.

---

# Step 1 — Start an Nginx Container

## Purpose

Launch a simple container that will later be inspected.

## Command

```bash
docker run -d --name my-test-nginx -p 8080:80 nginx
```

Verify that the container is running.

```bash
docker ps
```

## Expected Output

The container should appear in the running container list.

## Observation

Docker has started a new isolated Linux process.

Screenshot:

```
screenshots/01-docker-run.png
```

---

# Step 2 — Find the Host Process ID

## Purpose

Identify the actual Linux process created by Docker.

## Command

```bash
docker inspect --format '{{ .State.Pid }}' my-test-nginx
```

Example:

```
1798
```

## Observation

This PID belongs to the host operating system.

Docker containers are visible from the host because they are ordinary Linux processes.

Screenshot:

```
screenshots/02-container-pid.png
```

---

# Step 3 — Verify the Process on the Host

## Purpose

Confirm that the process actually exists on the host.

## Command

```bash
ps aux | grep 1798
```

## Observation

The host can see the nginx process normally.

At this point there is no "magic."

The container process is simply another process managed by Linux.

Screenshot:

```
screenshots/03-host-process.png
```

---

# Step 4 — Enter the Container Namespace

## Purpose

Join the namespaces used by the running container.

## Command

```bash
sudo nsenter \
--target 34872 \
--mount \
--uts \
--ipc \
--net \
--pid
```

After entering:

```bash
hostname
```

Screenshot:

```
screenshots/04-nsenter.png
```

---

# Observation

Notice the difference.

Before entering:

Host sees every running process.

After entering:

Only the processes inside the namespace remain visible.

The nginx master process now becomes **PID 1**.

This demonstrates that the Linux Kernel has created an isolated process tree.

---

# Technical Analysis

Docker did not create another operating system.

Instead, Linux Kernel created a new PID Namespace.

Inside that namespace:

* Process numbering starts again.
* PID 1 becomes nginx.
* Host processes disappear.
* Process isolation is achieved without virtualization.

This experiment proves that Docker containers are isolated Linux processes sharing the host kernel.

---

# Screenshots

```
screenshots/

01-docker-run.png

02-container-pid.png

03-host-process.png

04-nsenter.png

```

---

# Key Takeaways

* Containers are Linux processes.
* Docker is a management layer.
* Linux Kernel provides process isolation.
* PID Namespace changes process visibility.
* Virtual Machines and Containers use different isolation models.

---

# Next Lab

The next experiment explores **Linux cgroups** to understand how Docker limits CPU and memory usage.

Topics include:

* CPU quota
* Memory limits
* OOM Killer
* Docker resource constraints

---

# References

* Docker Documentation
* Linux Kernel Documentation
* man namespaces
* man nsenter
* Open Container Initiative (OCI)
