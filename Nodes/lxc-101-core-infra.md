# LXC 101 — Core Infrastructure

LXC 101 merupakan container yang menjalankan layanan infrastruktur inti yang menjadi dependency utama bagi service lain dalam environment homelab.

## Container Information

| Component        | Details                |
| ---------------- | ---------------------- |
| CT ID            | 101                    |
| Hostname         | `core-infra`           |
| Operating System | Ubuntu 24.04 LTS       |
| CPU              | 2 cores                |
| Memory           | 768MB RAM + 512MB Swap |
| Storage          | 8GB (`local-lvm`)      |
| Type             | Unprivileged LXC       |
| Docker Support   | Nesting enabled        |

## Network Configuration

| Configuration | Value                |
| ------------- | -------------------- |
| IP Address    | `192.168.100.101/24` |
| Gateway       | `192.168.100.1`      |
| DNS Server    | `1.1.1.1`            |
| Search Domain | `homelab.local`      |

> LXC 101 menggunakan external DNS dan tidak menggunakan Pi-hole sebagai DNS resolver untuk menghindari circular dependency. Detail desain DNS dijelaskan pada `Infrastructure/network.md`.

## Service Architecture

LXC 101 menyediakan beberapa layer infrastruktur inti yang menjadi foundation bagi seluruh environment homelab.

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

Setiap layer memiliki tanggung jawab yang berbeda:

| Layer            | Service             | Responsibility                                                |
| ---------------- | ------------------- | ------------------------------------------------------------- |
| DNS Layer        | Pi-hole             | Internal DNS resolution dan ad blocking untuk seluruh network |
| Ingress Layer    | Nginx Proxy Manager | Reverse proxy, domain routing, dan SSL termination            |
| Management Layer | Portainer           | Docker environment management dan container administration    |
| Dashboard Layer  | Homepage            | Centralized dashboard untuk akses seluruh internal service    |
| Monitoring Layer | Uptime Kuma         | Service health monitoring dan availability tracking           |




## Hosted Services

| Service             | Purpose                                      |
| ------------------- | -------------------------------------------- |
| Pi-hole             | Internal DNS resolver dan ad blocking        |
| Nginx Proxy Manager | Reverse proxy dan SSL termination            |
| Portainer           | Docker management interface                  |
| Homepage            | Internal service dashboard                   |
| Uptime Kuma         | Service monitoring dan availability checking |

LXC 101 memiliki startup priority tertinggi pada Proxmox karena menyediakan DNS dan reverse proxy yang digunakan oleh service lain.

## Dependencies

### Depends On

* Proxmox host dan network availability

### Required By

* Seluruh LXC dan VM yang menggunakan Pi-hole sebagai DNS.
* Seluruh internal service yang diakses melalui Nginx Proxy Manager.

## Related Services

* `Services/pihole.md`
* `Services/nginx-proxy-manager.md`
* `Services/portainer.md`
* `Services/homepage.md`
* `Services/uptime-kuma.md`

## Related Runbooks

* `Runbooks/lxc-ubuntu-post-install.md` — Initial package update, Docker installation, dan base configuration.
* `Runbooks/pihole-deployment.md` — Deployment dan konfigurasi Pi-hole.
* `Runbooks/npm-deployment.md` — Deployment Nginx Proxy Manager.
* `Runbooks/docker-service-deployment.md` — Deployment service berbasis Docker.

---

*Last updated: 2026-06-17*
