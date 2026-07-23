# Linux Container Internals

A hands-on repository documenting my journey to understand how Docker works internally using native Linux Kernel features.

The goal of this repository is to explore the technologies behind containers instead of treating Docker as a black box.

## Topics

- Linux Namespaces
- cgroups
- OverlayFS
- Process Isolation
- Network Namespace
- PID Namespace
- Mount Namespace
- UTS Namespace

---

## Labs

| Lab | Topic | Status |
|------|------|--------|
| Lab 01 | Exploring PID Namespace with nsenter | ✅ |
| Lab 02 | Understanding cgroups | Coming Soon |
| Lab 03 | OverlayFS | Coming Soon |
| Lab 04 | Network Namespace | Coming Soon |

---

## Why this repository?

Docker itself does not create containers.

Containers are built using existing Linux Kernel features such as:

- Namespaces
- cgroups
- OverlayFS
- Capabilities

This repository documents experiments proving those concepts using practical labs.
