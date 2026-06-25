# LXC 101 — Core Infrastructure

LXC 101 merupakan container yang menjalankan layanan infrastruktur inti yang menjadi foundation bagi seluruh environment homelab.

## Container Information

| Component | Details |
|---|---|
| CT ID | 101 |
| Hostname | `core-infra` |
| Operating System | Ubuntu 24.04 LTS |
| CPU Allocation | 2 cores |
| Memory | 768MB RAM + 512MB Swap |
| Storage | 8GB (`local-lvm`) |
| Container Type | Unprivileged LXC |
| Docker Support | Nesting enabled |

## Network Configuration

| Configuration | Value |
|---|---|
| IP Address | `192.168.100.101/24` |
| Gateway | `192.168.100.1` |
| DNS Server | `1.1.1.1` |
| Search Domain | `homelab.local` |

> LXC 101 menggunakan external DNS dan tidak menggunakan Pi-hole sebagai DNS resolver untuk menghindari circular dependency. Detail desain DNS dijelaskan pada `Infrastructure/network.md`.

## Service Architecture

LXC 101 menyediakan beberapa layer infrastruktur yang menjadi foundation bagi seluruh environment homelab.

```text
                 LXC 101 — Core Infrastructure
                            |
          ┌─────────────────┼─────────────────┐
          |                 |                 |
      DNS Layer       Ingress Layer    Management Layer
          |                 |                 |
       Pi-hole             NPM            Portainer
                            |
                  ┌─────────┴─────────┐
                  |                   |
           Dashboard Layer     Monitoring Layer
                  |                   |
              Homepage          Uptime Kuma
```

Setiap layer memiliki tanggung jawab yang berbeda:

| Layer | Service | Responsibility |
|---|---|---|
| DNS Layer | Pi-hole | Internal DNS resolution dan ad blocking untuk seluruh network |
| Ingress Layer | Nginx Proxy Manager | Reverse proxy, domain routing, dan SSL termination |
| Management Layer | Portainer | Docker environment management dan container administration |
| Dashboard Layer | Homepage | Centralized dashboard untuk akses internal service |
| Monitoring Layer | Uptime Kuma | Service health monitoring dan availability tracking |

## Hosted Services

| Service | Role | Documentation |
|---|---|---|
| Pi-hole | DNS resolver & ad blocking | `Services/pihole.md` |
| Nginx Proxy Manager | Reverse proxy & SSL management | `Services/nginx-proxy-manager.md` |
| Portainer | Docker management | `Services/portainer.md` |
| Homepage | Internal dashboard | `Services/homepage.md` |
| Uptime Kuma | Service monitoring | `Services/uptime-kuma.md` |

## Dependency Relationship

### Depends On

- Proxmox host availability
- Local network connectivity
- External DNS (`1.1.1.1`) untuk outbound DNS resolution

### Required By

- LXC 102 — Security
- LXC 103 — Database
- LXC 104 — Authentication
- LXC 105 — Productivity
- VM 100 — Home Assistant OS
- Seluruh client yang menggunakan internal DNS dan reverse proxy

LXC 101 memiliki startup priority tertinggi pada Proxmox karena menyediakan DNS dan ingress layer yang menjadi dependency utama bagi seluruh environment.

## Related Runbooks

- `Runbooks/lxc-base-setup.md` — Initial LXC setup, package update, Docker installation, dan base configuration.
- `Runbooks/docker-service-deployment.md` — General Docker service deployment workflow.

---

*Last updated: 2026-06-17*