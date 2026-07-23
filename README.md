Linux Container Internals

Hands-on experiments exploring how Linux Kernel powers modern container technologies.

📖 Overview

Modern container platforms such as Docker, containerd, CRI-O and Kubernetes are all built on top of Linux Kernel primitives.

Instead of treating Docker as a black box, this repository documents practical experiments that demonstrate how containers actually work under the hood.

Every lab focuses on understanding one Linux Kernel feature through hands-on exercises.

🎯 Objectives

This repository aims to:

Understand Linux Namespaces
Learn how cgroups limit resources
Explore OverlayFS and Copy-on-Write
Analyze Docker networking internals
Study container security
Build production-ready DevOps knowledge
🧱 Repository Structure
labs/
    lab01-linux-pid-namespace/
    lab02-cgroups/
    lab03-overlayfs/
    ...
📚 Learning Roadmap
Lab	Topic	Status
01	Linux PID Namespace	✅ Completed
02	Linux cgroups	🚧
03	OverlayFS	🚧
04	Network Namespace	🚧
05	Virtual Ethernet (veth)	🚧
06	iptables / NAT	🚧
07	Rootless Containers	🚧
08	Linux Capabilities	🚧
09	Seccomp	🚧
10	Container Runtime	🚧
🖥 Environment
Ubuntu Server
Docker Engine
Linux Kernel
Bash
Git
🎯 Goal

This repository is maintained as a long-term engineering notebook documenting my journey from Linux Administration to DevOps and DevSecOps.
