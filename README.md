# 🏠 Homelab Infrastructure Documentation

Personal self-hosted homelab environment built on Proxmox VE using LXC containers, Docker services, and a modular infrastructure architecture.

This repository serves as the single source of truth for infrastructure configuration, service architecture, operational procedures, and deployment runbooks.

---

# Architecture Overview

```text
Internet
   │
   ▼
Router (192.168.100.1)
   │
   ▼
Proxmox VE Host
haytham (192.168.100.10)
   │
   ├── VM 100 — Home Assistant OS
   │
   ├── LXC 101 — Core Infrastructure
   │     ├── Pi-hole
   │     ├── Nginx Proxy Manager
   │     ├── Homepage
   │     ├── Uptime Kuma
   │     └── Portainer
   │
   ├── LXC 102 — Security
   │     └── Vaultwarden
   │
   ├── LXC 103 — Database
   │     ├── PostgreSQL
   │     ├── Redis
   │     └── Adminer
   │
   ├── LXC 104 — Authentication
   │     └── Authentik
   │
   └── LXC 105 — Productivity
         ├── Outline
         ├── Stirling PDF
         └── Postiz
```

---

# Technology Stack

| Category | Technology |
|---|---|
| Hypervisor | Proxmox VE |
| Container Platform | LXC + Docker |
| Reverse Proxy | Nginx Proxy Manager |
| DNS | Pi-hole |
| Password Manager | Vaultwarden |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| Identity Provider | Authentik |
| Documentation | Outline |
| Monitoring | Uptime Kuma |
| Remote Access | Tailscale |

---

# Repository Structure

```text
homelab/
│
├── Infrastructure/
│   ├── hardware.md
│   ├── network.md
│   ├── proxmox.md
│   └── tailscale.md
│
├── Nodes/
│   ├── 101-core-infrastructure.md
│   ├── 102-security.md
│   ├── 103-database.md
│   ├── 104-authentication.md
│   └── 105-productivity.md
│
├── Services/
│   ├── pihole.md
│   ├── nginx-proxy-manager.md
│   ├── homepage.md
│   ├── uptime-kuma.md
│   ├── portainer.md
│   ├── vaultwarden.md
│   ├── postgresql.md
│   ├── redis.md
│   ├── adminer.md
│   ├── authentik.md
│   ├── outline.md
│   ├── stirling-pdf.md
│   └── postiz.md
│
└── Runbooks/
    └── Deployment, maintenance,
        troubleshooting, and operational procedures
```

---

# Documentation Philosophy

This repository follows a layered documentation model:

## Infrastructure

Describes physical hardware, networking, Proxmox host configuration, and core architecture decisions.

**Question answered:**  
> What infrastructure exists?

---

## Nodes

Describes each Proxmox LXC/VM including its purpose, resource allocation, network identity, and hosted services.

**Question answered:**  
> Where does a service run?

---

## Services

Describes each application including its purpose, architecture, dependencies, security considerations, and backup requirements.

**Question answered:**  
> What does the service do?

---

## Runbooks

Contains operational procedures including deployment, upgrades, maintenance, backup, restore, and troubleshooting.

**Question answered:**  
> How do we operate it?

---

# Design Principles

This homelab is designed around several principles:

- **Self-hosted first** — maintain control over personal data and services.
- **Separation of concerns** — infrastructure, nodes, services, and operations are documented separately.
- **Security by default** — HTTPS, internal DNS, centralized credential management, and planned SSO integration.
- **Infrastructure as documentation** — every architectural decision should be recorded.
- **Recoverability** — services are designed with backup and restore procedures in mind.

---

# Current Status

| Component | Status |
|---|---|
| Infrastructure documentation | ✅ Complete |
| Node documentation | ✅ Complete |
| Service documentation | ✅ Complete |
| Deployment runbooks | 🔲 In progress |
| Backup & recovery procedures | 🔲 Planned |
| Disaster recovery documentation | 🔲 Planned |

---

# Future Roadmap

- Complete deployment runbooks
- Implement automated backup strategy
- Create disaster recovery procedures
- Improve monitoring and alerting
- Expand Home Assistant automation

---

*Last updated: 2026-06-18*