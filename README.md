# Linux Container Internals

> **A hands-on engineering repository exploring how modern Linux containers work under the hood using native Linux Kernel technologies.**

![Status](https://img.shields.io/badge/Status-In%20Progress-blue)
![Platform](https://img.shields.io/badge/Platform-Linux-green)
![Focus](https://img.shields.io/badge/Focus-DevOps%20%7C%20DevSecOps-orange)

---

# 📖 Overview

Modern container platforms such as **Docker**, **containerd**, **CRI-O**, and **Kubernetes** are all built on top of existing Linux Kernel technologies.

Many engineers know how to use Docker commands, but far fewer understand **what actually happens inside the Linux Kernel** after executing commands like:

```bash
docker run
```

This repository documents my journey of learning **Container Internals** from first principles.

Rather than treating Docker as a black box, each lab investigates the underlying Linux technologies that make containers possible.

Every experiment is performed on a real Linux environment and documented with:

* Objectives
* Architecture
* Commands
* Screenshots
* Observations
* Technical Analysis
* Security Considerations
* Lessons Learned

The goal is to understand **why** containers work—not just **how** to use Docker.

---

# 🎯 Objectives

The primary objectives of this repository are:

* Understand how Linux Kernel implements containers.
* Learn the internal architecture of Docker.
* Explore Linux Namespaces.
* Explore Linux cgroups.
* Understand OverlayFS and Copy-on-Write.
* Study Linux networking used by containers.
* Learn container security from a DevSecOps perspective.
* Build production-oriented knowledge instead of memorizing commands.

---

# 🧠 Learning Philosophy

This repository follows one simple principle:

> **Every Docker feature should be explained by the Linux Kernel feature behind it.**

Instead of asking:

> "How do I use Docker?"

I ask:

> "How does Docker achieve this internally?"

For every topic, I try to answer four questions:

1. What problem does this technology solve?
2. How does Linux Kernel implement it?
3. How does Docker make use of it?
4. Why does it matter in production environments?

---

# 🏗 Repository Structure

```text
linux-container-internals/

│

├── README.md

├── LICENSE

├── CHANGELOG.md

├── docs/

│ ├── roadmap.md

│ ├── glossary.md

│ └── references.md

│

├── assets/

│ ├── diagrams/

│ └── images/

│

└── labs/

├── lab01-linux-pid-namespace/

├── lab02-cgroups/

├── lab03-overlayfs/

├── lab04-network-namespace/

├── lab05-veth-pair/

├── lab06-iptables/

├── lab07-rootless-container/

├── lab08-linux-capabilities/

├── lab09-seccomp/

└── lab10-mini-container-runtime/
```

Each laboratory contains:

* README.md
* screenshots/
* commands.md (optional)
* diagrams (optional)

---

# 🗺 Learning Roadmap

| Lab | Topic                    | Description                       | Status      |
| --- | ------------------------ | --------------------------------- | ----------- |
| 01  | Linux PID Namespace      | Process Isolation using `nsenter` | ✅ Completed |
| 02  | Linux cgroups            | CPU & Memory Resource Limits      | 🚧 Planned  |
| 03  | OverlayFS                | Container Filesystem Architecture | 🚧 Planned  |
| 04  | Network Namespace        | Container Networking              | 🚧 Planned  |
| 05  | veth Pair & Linux Bridge | Virtual Networking                | 🚧 Planned  |
| 06  | iptables & NAT           | Packet Forwarding                 | 🚧 Planned  |
| 07  | Rootless Containers      | Running Containers Securely       | 🚧 Planned  |
| 08  | Linux Capabilities       | Privilege Management              | 🚧 Planned  |
| 09  | Seccomp & AppArmor       | Kernel Security                   | 🚧 Planned  |
| 10  | Build a Mini Container   | Implementing a Simple Runtime     | 🚧 Planned  |

---

# 🏛 Container Architecture

```text
                +----------------------+
                |      Application     |
                +----------------------+
                |     Docker Engine    |
                +----------------------+
                | Linux Kernel Features|
                |----------------------|
                | • Namespaces         |
                | • cgroups            |
                | • OverlayFS          |
                | • Capabilities       |
                | • Netfilter          |
                +----------------------+
                |      Hardware        |
                +----------------------+
```

Docker does **not** create containers from scratch.

Instead, Docker orchestrates existing Linux Kernel features.

---

# 🔬 Topics Covered

This repository focuses on the following Linux technologies.

## Process Isolation

* PID Namespace
* Process Tree
* init (PID 1)

---

## Filesystem

* OverlayFS
* Copy-on-Write
* Writable Layer

---

## Resource Management

* cgroups
* CPU Limits
* Memory Limits
* OOM Killer

---

## Networking

* Network Namespace
* Virtual Ethernet (veth)
* Linux Bridge
* iptables
* NAT

---

## Security

* Rootless Containers
* Linux Capabilities
* Seccomp
* AppArmor
* Read-only Filesystem

---

# 💻 Lab Environment

The experiments are performed using the following environment.

| Component        | Version       |
| ---------------- | ------------- |
| Operating System | Ubuntu Linux  |
| Docker Engine    | Latest Stable |
| Linux Kernel     | 6.x           |
| Git              | Latest Stable |
| Bash             | GNU Bash      |

Future labs may include:

* containerd
* Kubernetes
* Kind
* Minikube
* Helm

---

# 🎓 Learning Method

Every lab follows the same engineering workflow.

```text
Problem

↓

Theory

↓

Architecture

↓

Experiment

↓

Observation

↓

Analysis

↓

Security Discussion

↓

Lessons Learned

↓

Production Insight
```

This structure encourages understanding instead of memorization.

---

# 📸 Screenshots

Each experiment includes screenshots documenting the execution.

Example:

```text
screenshots/

01-command.png

02-output.png

03-analysis.png
```

This allows experiments to be easily reproduced and verified.

---

# 📚 References

Official documentation is prioritized throughout this repository.

Primary references include:

* Docker Documentation
* Linux Kernel Documentation
* Linux man pages
* CNCF Documentation
* OCI (Open Container Initiative)

---

# 🚀 Future Goals

After completing this repository, the next learning milestones include:

* Docker Networking
* Kubernetes Architecture
* Helm
* GitOps
* Terraform
* CI/CD Pipelines
* DevSecOps
* Cloud Native Security

---

# 🤝 Contributing

This repository is maintained as a personal engineering notebook.

Suggestions, improvements, and technical discussions are always welcome.

---

# 📄 License

This project is licensed under the MIT License.

---

# ⭐ Final Note

Containers are **not** lightweight virtual machines.

They are isolated Linux processes created using Kernel primitives such as Namespaces and cgroups.

Understanding these fundamentals is essential for building reliable, secure, and production-ready containerized systems.

This repository documents that learning journey through practical experiments and technical analysis.
